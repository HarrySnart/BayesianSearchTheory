/* LOGIC FOR UPDATING PROBABILITIES 

this script defines a macro which

- loads most recent probability table
- updates it based on most recent unsuccessful search

*/

%macro updateSearchHistory();
proc iml;

/* matrix of probabilities of prior belief of where object is most likely to be */
use work.prob_loc; 
read all var {"prob"} ;
close work.prob_loc;

prob_loc = shape(prob,4,4);

/* matrix of probabilities of how likely it is to find object given complexity of search space (e.g. depth, murkiness, hazards...) */
use work.prob_dep; 
read all var {"prob"} ;
close work.prob_dep;

prob_dep = shape(prob,4,4);

use work.prob_total; 
read all var {"PROB_TOT_OUT"} ;
close work.prob_total;

prob_tot = shape(prob_tot_out,4,4);


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

/* update probability of location using bayes theorem */
p_is_there = prob_loc[row_max,col_max];
p_found_if_there = prob_dep[row_max,col_max];

updated_prob_num = p_is_there * (1 - p_found_if_there);
updated_prob_denum = ((1 - p_is_there) + p_is_there * (1-p_found_if_there));

updated_prob = updated_prob_num / updated_prob_denum; *NOTE: this updates the prob of just the recently searched area;

/* Update all probabilities of other areas not already searched. This needs doing before re-calc of total prob */

prob_loc = shape(prob_loc,16,1);
prob_dep_ref = shape(prob_dep,16,1);

do i = 1 to 16;
p_is_there = prob_loc[i];
p_found_is_there = prob_dep_ref[i];
new_prob = p_is_there / ((1 - p_is_there) + (p_is_there * (1 - p_found_is_there)));
prob_loc[i] = new_prob;
end;

prob_loc = shape(prob_loc,4,4);

/* Updated Probability following unsuccessful search */

prob_loc[row_max,col_max] = updated_prob;

/* update total probability */
prob_tot = prob_loc # prob_dep;

new_search_zone = prob_tot[<:>];

new_max = ind2sub(ncol(prob_tot),new_search_zone);

/* return matrix index for best guess location */
row_max = new_max[1];
col_max = new_max[2];

y = (4 - row_max) + 1;
x = col_max;

create next_search_zone var {y,x};
append;
close next_search_zone;

/* return updated probability table */
prob_tot_out = shape(prob_tot,16,1);
prob_loc_out = shape(prob_loc,16,1);

/* get y,x pairs from input data */
use work.prob_loc; 
read all var {"y","x"} ;
close work.prob_loc;

create prob_total var {y,x,prob_tot_out};
append;
close prob_total;

prob = prob_loc_out;

create prob_loc var {y,x,prob};
append;
close prob_loc;

quit;


/* UPDATE HISTORY TABLES

- update search history
- update probability history

 */

/* get current search day */
proc sql noprint; select max(search_day) into :currDay from search_hist; quit;

/* post-process updated probability table */
data prob_tot_temp;
set prob_total;
search_day = &currDay + 1;
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

/* merge with probability history table */
data prob_total_hist;
set prob_total_hist prob_tot_temp;
run;

/* post-process updated probability table */
data prob_loc_temp;
set prob_loc;
search_day = &currDay + 1;
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

/* merge with probability history table */
data prob_loc_hist;
set prob_loc_hist prob_loc_temp;
run;

/* post-process updated search zone table */
data search_zone_temp;
set next_search_zone;
search_day = &currDay + 1;
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
set search_hist search_zone_temp;
run;
%mend;