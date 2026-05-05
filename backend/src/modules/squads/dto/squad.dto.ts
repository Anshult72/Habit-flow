import { IsString, IsNumber, Min, Max, IsNotEmpty } from 'class-validator';

export class CreateSquadDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsNumber()
  @Min(0)
  entryXP: number;

  @IsNumber()
  @Min(7)
  @Max(90)
  durationDays: number;
}
