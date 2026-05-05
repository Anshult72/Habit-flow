import { Test, TestingModule } from '@nestjs/testing';
import { SquadsController } from './squads.controller';

describe('SquadsController', () => {
  let controller: SquadsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SquadsController],
    }).compile();

    controller = module.get<SquadsController>(SquadsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
