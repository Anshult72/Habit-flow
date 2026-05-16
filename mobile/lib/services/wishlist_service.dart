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
    // This requires backend resolution, cannot be strictly offline.
    // If offline, it should throw so the UI can warn the user.
    final response = await _dio.post('/targets/auto-sync', data: {'url': url});
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
    return ref.watch(wishlistServiceProvider).getWishlist();
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
