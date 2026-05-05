import { IsString, IsNumber, Min, Max, IsNotEmpty } from 'class-validator';

export class CreateChallengeDto {
  @IsNumber()
  @Min(0)
  entryXP: number;

  @IsNumber()
  @Min(7)
  @Max(90)
  durationDays: number;

  @IsString()
  @IsNotEmpty()
  targetUserId: string;
}
