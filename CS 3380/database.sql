create database if not exists cs3380;

use cs3380

create table if not exists rstInfo (
	Figure int(1),
	ContrailsInFigure int(2),
	BlockRadius int(2),
	Percentage int(2),
	FillGap int(3),
	MinimumLength int(3),
	CorrectContrailNumber int(2),
	IncorrectContrailNumber int(2),
	MissingContrailNumber int(2),
	CorrectRate decimal(3,2),
	IncorrectRate decimal(3,2)
);
