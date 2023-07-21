
/* This script implements bayesian search theory for a 250 day search effort.

Firstly, we iniailize our probabilities. these come from 

1 - our beliefs on where the object is, such as last known location
2 - our subject matter understanding of the search complexity of each search zone

each search represents one day of search effort in a given search zone. 

a zone represents an area where search is being concentrated by a salvage team

each day our plan changes on where to focus effort. this is more efficient than random search or exhaustive search of just one zone

whilst this is a simple demo, this approach has been used for major search missions including
- USS Scorpion
- USS Thresher
- MV Derbyshire
- SS Central America
- Air France 447
- Malaysia Airlines 370

This approach is used by US Coast Guard, US Air Force and Civil Air Patrol.

More information here: https://en.wikipedia.org/wiki/Bayesian_search_theory  
Maths explained here: https://www.lancaster.ac.uk/stor-i-student-sites/katie-howgate/2021/02/08/a-bayesian-approach-to-finding-lost-objects/
*/

title 'Initial Probabilities';

/* Load macro used to update probabilities between simulated search days */
%include "./Update Search.sas"; 

/* INITIALIZE PROBABILITIES AND SEARCH DATA */

/* calculate prior probabilities by combining total prob of prior knowledge */

/* this first dataset is a series representing the best guess of where the object was lost (from where it was last seen and movement of current etc.) */
data prob_loc;
input y x prob ;
datalines;
4 1 0.02
4 2 0.02
4 3 0.02
4 4 0.01
3 1 0.08
3 2 0.17
3 3 0.17
3 4 0.01
2 1 0.08
2 2 0.17
2 3 0.17
2 4 0.01
1 1 0.02
1 2 0.02
1 3 0.02
1 4 0.01
;

/* this second dataset represents the likelihood of finding the lost object given that it is actually there. this represents the search effort required in a given space.  */
data prob_dep;
input y x prob;
datalines;
4 1 0.91
4 2 0.97
4 3 0.97
4 4 0.98
3 1 0.86
3 2 0.29
3 3 0.69
3 4 0.99
2 1 0.67
2 2 0.65
2 3 0.86
2 4 0.97
1 1 0.99
1 2 0.91
1 3 0.92
1 4 0.97
;

/* preparing initial prior probabilities using matrix multiplication */

proc iml;
use work.prob_loc; 
read all var {"prob"} ;
close work.prob_loc;

prob_loc = shape(prob,4,4);
print prob_loc[label="Probability of Actual Location"];

/* matrix of probabilities of how likely it is to find object given complexity of search space (e.g. depth, murkiness, hazards...) */
use work.prob_dep; 
read all var {"prob"} ;
close work.prob_dep;

prob_dep = shape(prob,4,4);
print prob_dep[label="Probability of Finding Object Given It is There"];

/* combined total probability of most likely place object is */
prob_tot = prob_loc # prob_dep;

print prob_tot[label="Total Probability of Finding Object in Search Zone"];

prob_tot_out = shape(prob_tot,16,1);

/* get y,x pairs from input data */
use work.prob_loc; 
read all var {"y","x"} ;
close work.prob_loc;

create prob_total var {y,x,prob_tot_out};
append;
close prob_total;

/* return initial search location */

/* add custom module to determine row/col of max prob */
start ind2sub( p, ind );
   idx = colvec(ind);
   n = nrow(idx);
   col = 1 + mod(idx-1, p);
   row = 1 + (idx-col) / p;
   return ( row || col );
finish;

/* find location in prior with highest prob of successful search */
max_tot = prob_tot[<:>];

loc_max = ind2sub(ncol(prob_tot),max_tot);

/* return matrix index for best guess location */
row_max = loc_max[1];
col_max = loc_max[2];

y = (4 - row_max) + 1;
x = col_max;

create next_search_zone var {y,x};
append;
close next_search_zone;

quit;


/* create initial time indexes */

data prob_total_hist;
set prob_total;
search_day = 0;
/* add logic for zone */
if y=4 and x=1 then zone = 1;
else if y=4 and x=2 then zone = 2;
else if y=4 and x=3 then zone = 3;
else if y=4 and x=4 then zone = 4;
else if y=3 and x=1 then zone = 5;
else if y=3 and x=2 then zone = 6;
else if y=3 and x=3 then zone = 7;
else if y=3 and x=4 then zone = 8;
else if y=2 and x=1 then zone = 9;
else if y=2 and x=2 then zone = 10;
else if y=2 and x=3 then zone = 11;
else if y=2 and x=4 then zone = 12;
else if y=1 and x=1 then zone = 13;
else if y=1 and x=2 then zone = 14;
else if y=1 and x=3 then zone = 15;
else if y=1 and x=4 then zone = 16;
run;

data search_hist;
set next_search_zone;
search_day = 0;
/* add logic for zone */
if y=4 and x=1 then zone = 1;
else if y=4 and x=2 then zone = 2;
else if y=4 and x=3 then zone = 3;
else if y=4 and x=4 then zone = 4;
else if y=3 and x=1 then zone = 5;
else if y=3 and x=2 then zone = 6;
else if y=3 and x=3 then zone = 7;
else if y=3 and x=4 then zone = 8;
else if y=2 and x=1 then zone = 9;
else if y=2 and x=2 then zone = 10;
else if y=2 and x=3 then zone = 11;
else if y=2 and x=4 then zone = 12;
else if y=1 and x=1 then zone = 13;
else if y=1 and x=2 then zone = 14;
else if y=1 and x=3 then zone = 15;
else if y=1 and x=4 then zone = 16;
run;


data prob_loc_hist;
set prob_loc;
search_day = 0;
/* add logic for zone */
if y=4 and x=1 then zone = 1;
else if y=4 and x=2 then zone = 2;
else if y=4 and x=3 then zone = 3;
else if y=4 and x=4 then zone = 4;
else if y=3 and x=1 then zone = 5;
else if y=3 and x=2 then zone = 6;
else if y=3 and x=3 then zone = 7;
else if y=3 and x=4 then zone = 8;
else if y=2 and x=1 then zone = 9;
else if y=2 and x=2 then zone = 10;
else if y=2 and x=3 then zone = 11;
else if y=2 and x=4 then zone = 12;
else if y=1 and x=1 then zone = 13;
else if y=1 and x=2 then zone = 14;
else if y=1 and x=3 then zone = 15;
else if y=1 and x=4 then zone = 16;
run;

/* RUN SIMULATIONS FOR MULTIPLE SEARCHES (250 Days of effort) */

%macro runSimulations();

%do i=1 %to 250;
	%updateSearchHistory();
%end;
%mend;

%runSimulations();