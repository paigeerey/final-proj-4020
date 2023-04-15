*	Paige Reynolds												*
*	PROJECT: Analyzing Election Results;						*
*	Data Set from: dataverse.harvard.edu						*;

ODS GRAPHICS ON ;
OPTIONS NODATE NONUMBER ORIENTATION=LANDSCAPE;

*	ACCESSING DATA;												*

*	The import statement points to the excel file in			*
*	my file directory and exports it to the work library		*;

PROC IMPORT OUT=WORK.president DATAFILE="/home/pereyno/president_data.xlsx" 
		DBMS=XLSX REPLACE;
run;

*	CLEANING DATA												*;

DATA president1;
	SET work.president;
	statepercent=(candidatevotes/totalvotes)*100;
	IF candidate=" " then candidate="N/A";
	FORMAT candidatevotes totalvotes comma10.;
	FORMAT statepercent 8.2;
	DROP writein party_detailed version state_po state_fips state_ic state_cen 
		office;
run;

PROC SORT DATA=work.president1;
	BY year state DESCENDING statepercent;
run;

DATA winning_party;
	SET work.president1;
	BY year state;
	IF first.state then output;
run;

DATA sc_president;
	SET work.president;
	BY year;
	statepercent=(candidatevotes/totalvotes)*100;
	IF candidate=" " then candidate="N/A";
	FORMAT candidatevotes totalvotes comma10.;
	FORMAT statepercent 8.2;
	WHERE state_po="SC";
	DROP writein party_detailed version state_po state_fips state_ic state_cen 
		office;
run;

PROC SORT DATA=work.sc_president;
	BY year DESCENDING statepercent;
run;

DATA winning_partysc;
	SET work.sc_president;
	BY year;
	IF first.year then output;
run;

ODS PDF FILE="&outpath/President.pdf" STYLE=BARRETTSBLUE PDFTOC=0;


*	EXPLORING DATA - FIRST 20 OBSERVATIONS						*;

PROC PRINT DATA=work.president1(OBS=20) NOOBS;
run;


PROC PRINT DATA=work.winning_party(OBS=20) NOOBS;
run;

PROC PRINT DATA=work.sc_president(OBS=20) NOOBS;
run;

PROC PRINT DATA=work.winning_partysc (OBS=20) NOOBS;
run;

*	ANALYZING AND MODELING DATA									*;

ODS NOPROCTITLE;

PROC SGPLOT DATA = work.winning_party;
	VBAR year / GROUP=party_simplified GROUPDISPLAY=CLUSTER;
	TITLE 'Political Party Results Since 1976';
RUN;

PROC FREQ DATA=work.winning_party;
	TABLES party_simplified*year / NOCUM NOROW NOPERCENT;
run;

title1 'Voter Turnout Since 1976: DEMOCRAT';
PROC MEANS DATA=work.winning_party SUM NONOBS;
	CLASS year;
	WHERE party_simplified='DEMOCRAT';
	VAR candidatevotes;
run;

title1 'Voter Turnout Since 1976: REPUBLICAN';
PROC MEANS DATA=work.winning_party SUM NONOBS;
	CLASS year;
	WHERE party_simplified='REPUBLICAN';
	VAR candidatevotes;
run;


title1 '2020 Political Party Results';
proc gchart data=work.winning_party;
	pie party_simplified / value=arrow percent=arrow noheading percent=inside 
		plabel=(height=8pt) slice=inside value=none name='PieChart';
	WHERE year=2020;
run;

title1 'TOTAL Trump Votes 2020';
PROC MEANS DATA=work.president1 SUM;
	WHERE SUBSTR(candidate,1,5)='TRUMP' and year=2020;
	VAR candidatevotes;
run;

title1 'TOTAL Biden Votes 2020';
PROC MEANS DATA=work.president1 SUM;
	WHERE SUBSTR(candidate,1,5)='BIDEN' and year=2020;
	VAR candidatevotes;
run;

title1 'States Winning Political Party Since 1976: South Carolina';
proc gchart data=work.winning_partysc;
	pie party_simplified / value=arrow percent=arrow noheading percent=inside 
		plabel=(height=8pt) slice=inside value=none name='PieChart';
	run;
quit;

PROC SGPLOT DATA = work.winning_partysc;
	VBAR party_simplified;
RUN;

title1 'Voter Turnout Progression';
PROC SGPLOT DATA = work.winning_partysc;
	SERIES X=year Y=totalvotes / LEGENDLABEL='Total Votes'
 MARKERS LINEATTRS = (THICKNESS = 2);
	XAXIS TYPE= DISCRETE;
run;

*	EXPORTING DATA TO PDF									*;
*	NOTE: The ODS PDF statement is listed previously		*;


ODS GRAPHICS OFF;
ODS PDF CLOSE;




