import 'dart:io';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

class WishlistService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _cacheKey = 'wishlist_cache';

  WishlistService(this._dio, this._localStorage, this._syncManager);

  List<WishlistModel> _getCachedWishlist() {
    final cachedData = _localStorage.readData(_cacheKey);
    if (cachedData != null) {
      return (cachedData as List).map((e) => WishlistModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveToCache(List<WishlistModel> wishlist) async {
    await _localStorage.saveData(_cacheKey, wishlist.map((e) => e.toJson()).toList());
  }

  Future<List<WishlistModel>> getWishlist() async {
    List<WishlistModel> wishlist = _getCachedWishlist();

    try {
      final response = await _dio.get('/targets');
      wishlist = (response.data as List).map((e) => WishlistModel.fromJson(e)).toList();
      await _saveToCache(wishlist);
    } catch (e) {
      if (wishlist.isEmpty) rethrow;
    }

    return wishlist;
  }

  Future<List<WishlistModel>> fetchFromServer() async {
    final response = await _dio.get('/targets');
    final fresh = (response.data as List).map((e) => WishlistModel.fromJson(e)).toList();
    await _saveToCache(fresh);
    return fresh;
  }

  Future<WishlistModel> createWishItem(Map<String, dynamic> data) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempItem = WishlistModel.fromJson({
      'id': tempId,
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    final cachedWishlist = _getCachedWishlist();
    cachedWishlist.add(tempItem);
    await _saveToCache(cachedWishlist);

    await _syncManager.enqueueAction('POST', '/targets', data: data);

    return tempItem;
  }

  Future<WishlistModel> updateWishItem(String id, Map<String, dynamic> data) async {
    final cachedWishlist = _getCachedWishlist();
    final index = cachedWishlist.indexWhere((w) => w.id == id);
    
    WishlistModel? updatedItem;
    if (index != -1) {
      final oldItem = cachedWishlist[index];
      updatedItem = WishlistModel.fromJson({
        ...oldItem.toJson(),
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      cachedWishlist[index] = updatedItem;
      await _saveToCache(cachedWishlist);
    }

    await _syncManager.enqueueAction('PATCH', '/targets/$id', data: data);
    
    return updatedItem ?? WishlistModel.fromJson({'id': id, ...data});
  }

  Future<void> deleteWishItem(String id) async {
    final cachedWishlist = _getCachedWishlist();
    cachedWishlist.removeWhere((w) => w.id == id);
    await _saveToCache(cachedWishlist);

    await _syncManager.enqueueAction('DELETE', '/targets/$id');
  }

  Future<Map<String, dynamic>> autoSync(String url) async {
    var targetUrl = url.trim();
    if (targetUrl.startsWith('//')) {
      targetUrl = 'https:$targetUrl';
    } else if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://$targetUrl';
    }

    try {
      // 1. Direct residential client-side scraping (Mobile IP bypasses 99% of proxy/captcha blocks)
      final scraperDio = Dio();
      // Bypass SSL certificate validation to prevent HandshakeException on scraping
      (scraperDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

      String html = '';
      int redirectCount = 0;

      // Manually follow redirect hops to fully preserve custom headers (like User-Agent) across domains/subdomains.
      // Standard HTTP clients drop User-Agent headers on redirect, triggering a 403 Forbidden block.
      while (redirectCount < 5) {
        final response = await scraperDio.get(
          targetUrl,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => status != null && status < 400,
            headers: {
              'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
            receiveTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 8),
          ),
        );

        if (response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 303 || response.statusCode == 307 || response.statusCode == 308) {
          final location = response.headers.value('location');
          if (location != null && location.isNotEmpty) {
            var newUrl = location.trim();
            if (newUrl.startsWith('//')) {
              newUrl = 'https:$newUrl';
            } else if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
              final originalUri = Uri.parse(targetUrl);
              newUrl = '${originalUri.scheme}://${originalUri.host}$newUrl';
            }
            targetUrl = newUrl;
            redirectCount++;
            continue;
          }
        }

        html = response.data?.toString() ?? '';
        break;
      }

      if (html.isNotEmpty) {
        // Extract Title
        String? title;
        final titlePatterns = [
          '<meta[^>]*(?:property|name)=["\'](?:og:title|twitter:title|title)["\'][^>]*content=["\']([^"\']*)["\']',
          '<meta[^]*content=["\']([^"\']*)["\'][^>]*(?:property|name)=["\'](?:og:title|twitter:title|title)["\']',
          '<title[^>]*>([^<]*)</title>',
          'class=["\'][^\'"]*(?:yh1177|B_NuCI|a-size-large|productTitle)[^\'"]*["\'][^>]*>([^<]*)<',
          'id=["\']productTitle["\'][^>]*>([^<]*)<',
          '<h1[^>]*>([^<]*)</h1>',
        ];

        for (final pattern in titlePatterns) {
          final match = RegExp(pattern, caseSensitive: false, dotAll: true).firstMatch(html);
          if (match != null) {
            final val = match.group(1)?.trim();
            if (val != null && val.isNotEmpty) {
              title = val;
              break;
            }
          }
        }

        // Clean Title
        if (title != null && title.isNotEmpty) {
          title = title.replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll(RegExp(r'\s+'), ' ').trim();
          if (title.length > 80) {
            title = '${title.substring(0, 77)}...';
          }
        }

        // Extract Price
        double? price;
        final pricePatterns = [
          '<meta[^>]*(?:property|name)=["\'](?:og:price:amount|product:price:amount)["\'][^>]*content=["\']([0-9,.]+)["\']',
          '<meta[^]*content=["\']([0-9,.]+)["\'][^>]*(?:property|name)=["\'](?:og:price:amount|product:price:amount)["\']',
          '"price"\\s*:\\s*["\']?([0-9,.]+)["\']?',
          '"priceAmount"\\s*:\\s*["\']?([0-9,.]+)["\']?',
          'class=["\'][^\'"]*(?:_30jeq3|Nx9512|_16Jk6d|_1M511N)[^\'"]*["\'][^>]*>\\s*(?:₹|Rs\\.?)?\\s*([0-9,.]+)',
          'class=["\'][^\'"]*(?:a-price-whole|a-color-price)[^\'"]*["\'][^>]*>\\s*([0-9,.]+)',
          'id=["\']priceblock_[^"\']*["\'][^>]*>\\s*(?:₹|Rs\\.?)?\\s*([0-9,.]+)',
          '(?:₹|Rs\\.?)\\s*([0-9,]+(?:\\.[0-9]{2})?)',
        ];

        for (final pattern in pricePatterns) {
          final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
          if (match != null) {
            final val = match.group(1);
            if (val != null) {
              final parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
              if (parsed != null && parsed > 0) {
                price = parsed;
                break;
              }
            }
          }
        }

        if (title != null && title.isNotEmpty) {
          return {
            'title': title,
            'price': price ?? 0.0,
            'category': 'Wishlist',
          };
        }
      }
    } catch (e) {
      // Scraper failed, fallback silently to backend autoSync
    }

    // 2. Fallback to NestJS backend parser using the cleaned targetUrl
    final response = await _dio.post('/targets/auto-sync', data: {'url': targetUrl});
    return response.data;
  }
}

final wishlistServiceProvider = Provider((ref) {
  return WishlistService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistModel>>(() {
  return WishlistNotifier();
});

class WishlistNotifier extends AsyncNotifier<List<WishlistModel>> {
  @override
  Future<List<WishlistModel>> build() async {
    final service = ref.watch(wishlistServiceProvider);
    
    // 1. Instantly return local cached items for 0ms UI latency
    final cached = service._getCachedWishlist();
    
    // 2. Trigger silent background fetch in a microtask
    Future.microtask(() async {
      try {
        final fresh = await service.fetchFromServer();
        state = AsyncValue.data(fresh);
      } catch (e) {
        // Silently preserve cached items on error
      }
    });

    return cached;
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      await ref.read(wishlistServiceProvider).createWishItem(data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await ref.read(wishlistServiceProvider).updateWishItem(id, data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    try {
      await ref.read(wishlistServiceProvider).deleteWishItem(id);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}
