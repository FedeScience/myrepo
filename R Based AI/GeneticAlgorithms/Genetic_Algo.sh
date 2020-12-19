#@http://father-natures.blogspot.com/2013/04/implementing-genetic-algorithm-in-bash.html
#!/usr/bin/bash
##########################################################################################
# imporant global variables                                                              #
##########################################################################################
     # constants                                                                         #
     #####################################################################################
GENERATION=0           # our current generation, how long the simulation has been running
POOL_SIZE=${1:-6}      # how many candidates are alive at once
REPRO_CHANCE=${2:-30}  # in a generation, the chance (0 to 100) that a candidate will choose a mate
BEST_FITS=${3:-70}
MUTATION_RATE=${4:-75} # for each birth, the chance (0 to 100) that a mutation will occur
NUM_MUTATIONS=${5:-1}  # max number of mutations to apply to a single child
RETURN_CHANCE=${6:-40} # chance the best candidate comes back to save us...
CHURN_RATE=${7:-40}
NUM_SECONDS=${8:-300}
let "CHURN_RATE = POOL_SIZE - ((POOL_SIZE * CHURN_RATE) / 100)"

let "LAST = POOL_SIZE - 1"

let "BEST_FITS = (POOL_SIZE * BEST_FITS) / 100"   # our hottest candidates
if [ $BEST_FITS -lt 1 ]; then
   BEST_FITS=1
fi

BEST_VAL=99999
BEST_MATCH=""

TARGET_STRING="Hello, World!"   # determine our target string
LENGTH=${#TARGET_STRING}        # get the length of the target string
declare -a CANDIDATES           # our candidate population
declare -a TARGET_ARRAY         # used for our fitness function
declare -a CANDIDATE_ARRAY      # used for our fitness function
declare -a FITNESS              # matches the CANDIDATE_ARRAY, the fitness value of each member

CHROMOSOMES='AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz ~1!2@3#456^7&890_=+|;:,./<>?'
NUM_CHROMOSOMES=${#CHROMOSOMES}

echo "Pool Size: $POOL_SIZE          Repro Rate: $REPRO_CHANCE     Mutate Rate: $MUTATION_RATE"
echo "Return Rate: $RETURN_CHANCE       Best Fits: $BEST_FITS       Num Mutations: $NUM_MUTATIONS"
echo "Churn Rate: $CHURN_RATE/$POOL_SIZE       Run for $NUM_SECONDS seconds"
     #####################################################################################
     # useful scratch variables, I am including them here for reference only...          #
     #####################################################################################
LAST_PARENT=0      # marks the end of the parents in this generation, after this are the kids
POPULATION_SCORE=0 # used to show how close the population as a whole is getting

#echo ">>> $CHROMOSOMES <<<>>> $NUM_CHROMOSOMES <<<"
##########################################################################################
# helper functions                                                                       #
##########################################################################################
     #####################################################################################
     # int2char( index ) - will return the character at the indexed position in our
     #                     CHROMOSOMES string.
     #####################################################################################
int2char()
{
   TNDX=$1
   TCHAR=${CHROMOSOMES:$TNDX:1}
}

     #####################################################################################
     # char2int( myChar ) - gives a value to a given character based on the position of
     #                      that character in the CHROMOSOMES string.
     #####################################################################################
char2int()
{
   TCHAR="$1"
   TEMPSTR=${CHROMOSOMES%%${TCHAR}*}
   TVAL=${#TEMPSTR}
}

     #####################################################################################
     # get_value_array( index ) - produces an array of indexed values for each char in
     #                            our candidate string.  These can then be used to create
     #                            our fitness values by comparing against the target array
     #                            "abc" ==> 0 1 2
     #####################################################################################
get_value_array()
{
   INDEX=$1
   TSTR="${CANDIDATES[${INDEX}]}"
   TNDX=0
   while [ $TNDX -lt $LENGTH ]; do
      TCHAR=${TSTR:$TNDX:1}
      char2int "$TCHAR"
      CANDIDATE_ARRAY[$TNDX]=$TVAL
      let "TNDX += 1"
   done
}

     #####################################################################################
     # determine_fitness( index ) - compares a given candidate against the target string
     #                              by converting the candidate string into values and
     #                              seeing how far apart those values are from the target
     #                              string values.
     #####################################################################################
determine_fitness()
{
   INDEX=$1
   get_value_array $INDEX
   TFITNESS=0
   TNDX=0
   while [ $TNDX -lt $LENGTH ]; do
      let "TVAL = TARGET_ARRAY[$TNDX] - CANDIDATE_ARRAY[$TNDX]"
      if [ $TVAL -lt 0 ]; then
         let "TFITNESS = TFITNESS - TVAL"
      else
         let "TFITNESS = TFITNESS + TVAL"
      fi
      let "TNDX += 1"
   done
   FITNESS[${INDEX}]=$TFITNESS
}

     #####################################################################################
     # create_new_candidate() - creates a new random string of the appropriate length
     #####################################################################################
create_new_candidate()
{
   TEMPVAR=0
   TSTRING=""
   while [ $TEMPVAR -lt $LENGTH ]; do
      let "TNDX = RANDOM % NUM_CHROMOSOMES"
      int2char $TNDX
      TSTRING="${TSTRING}${TCHAR}"
      let "TEMPVAR += 1"
   done
}

     #####################################################################################
     # display_candidate( index ) - displays a single candidate in our population
     #####################################################################################
display_candidate()
{
   TMBR=$1
   printf "   %3s   %5s   >>> ${CANDIDATES[${TMBR}]} <<< \n" $TMBR ${FITNESS[${TMBR}]}
}

     #####################################################################################
     # generate_report() - displays the current population
     #####################################################################################
generate_report()
{
   TMBR=0
   while [ $TMBR -lt $POOL_SIZE ]; do
      display_candidate $TMBR
      let "TMBR += 1"
   done
}

     #####################################################################################
     # swap_candidates( index_1, index_2 ) - swaps entries in our arrays for these two
     #                                       candidates.
     #####################################################################################
swap_candidates()
{
   TMBR1=$1
   TMBR2=$2

   TSTR="${CANDIDATES[${TMBR1}]}"
   TVAL=${FITNESS[${TMBR1}]}

   CANDIDATES[${TMBR1}]="${CANDIDATES[${TMBR2}]}"
   FITNESS[${TMBR1}]=${FITNESS[${TMBR2}]}

   CANDIDATES[${TMBR2}]="$TSTR"
   FITNESS[${TMBR2}]=$TVAL
}

display_prodigy()
{
   printf ">>> %4s   Generation: %-5s   " $SECONDS $GENERATION
   printf "%15s" "( ${FITNESS[0]} to ${FITNESS[$LAST]} )"
   printf "   Prodigy: > $BEST_MATCH < with a score of $BEST_VAL\n"
}

     #####################################################################################
     # sort_candidate_pool() - sorts the pool arrays (CANDIDATES and FITNESS) placing the
     #                         most fit candidates at the top.  The most fit candidates
     #                         have a better chance of surviving and reproducing into the
     #                         next generation.
     #####################################################################################
sort_candidate_pool()
{
   # implement a simple bubble sort
   TMBR1=0                                      # the slot currently being inspected
   let "TMBR2 = POOL_SIZE - 1"                  # our last non-sorted slot
   while [ $TMBR2 -gt 0 ]; do
      TMBR1=0
      while [ $TMBR1 -lt $TMBR2 ]; do
         if [ ${FITNESS[${TMBR1}]} -gt ${FITNESS[${TMBR2}]} ]; then
            swap_candidates $TMBR1 $TMBR2       # place the biggest value in the last slot
         fi
         let "TMBR1 += 1"
      done
      let "TMBR2 -= 1"
   done

   if [ ${FITNESS[0]} -lt $BEST_VAL ]; then
      BEST_VAL=${FITNESS[0]}
      BEST_MATCH="${CANDIDATES[0]}"
      display_prodigy
   fi
}

     #####################################################################################
     # mutate_candidate( index ) - randomly change one character in our string
     #####################################################################################
mutate_candidate()
{
   TMBRX=$1
   TCNT=1
   while [ $TCNT -le $NUM_MUTATIONS ]; do
      PARENT1="${CANDIDATES[${TMBRX}]}"
      let "TNDX = RANDOM % LENGTH"   # pick a random character to mutate
      let "TLEN = LENGTH - TNDX - 1"
      if [ $TNDX -eq 0 ]; then
         SUBSTR_L=""
         SUBSTR_R="${PARENT1:1:${TLEN}}"
      elif [ $TLEN -eq 0 ]; then
         let "TLEN = LENGTH - 1"
         SUBSTR_L="${PARENT1:0:${TLEN}}"
         SUBSTR_R=""
      else
         SUBSTR_L="${PARENT1:0:${TNDX}}"
         let "TNDX += 1"
         SUBSTR_R="${PARENT1:${TNDX}:${TLEN}}"
      fi

      # now we mutate that spot
      let "TNDX = RANDOM % NUM_CHROMOSOMES"
      int2char $TNDX
      CANDIDATES[${TMBRX}]="${SUBSTR_L}${TCHAR}${SUBSTR_R}"
      let "TCNT += 1"
   done
   # echo ">>>>> Mutating child...     > $PARENT1 < ==> > ${SUBSTR_L}${TCHAR}${SUBSTR_R} <"
}

     #####################################################################################
     # create_offspring( index1, index2 ) - creates children for two parents
     #   "ABCDEFGH"    + "MNOPQRST"   ==> "????????" + "????????"
     #   "ABC","DEFGH" + "MNO","PQRST" - pick a random spot to do our split, eg. 3
     #   "ABCPQRST" , "MNODEFGH" - swap the pieces for our children
     #####################################################################################
create_offspring()
{
   TMBR1=$1
   TMBR2=$2
   PARENT1="${CANDIDATES[${TMBR1}]}"
   PARENT2="${CANDIDATES[${TMBR2}]}"

   let "TNDX = RANDOM % (LENGTH - 2) + 1"
   let "TLEN = LENGTH - TNDX"
   SUBSTR_X1="${PARENT1:0:${TNDX}}"
   SUBSTR_X2="${PARENT1:${TNDX}:${TLEN}}"
   SUBSTR_Y1="${PARENT2:0:${TNDX}}"
   SUBSTR_Y2="${PARENT2:${TNDX}:${TLEN}}"
   CHILD1="${SUBSTR_X1}${SUBSTR_Y2}"
   CHILD2="${SUBSTR_Y1}${SUBSTR_X2}"

   # the children will replace the worst candidates
   CANDIDATES[${TMBR1}]="$CHILD1"
   #   give each child a chance for a random mutation
   let "TEMP = RANDOM % 100"
   if [ $TEMP -le $MUTATION_RATE ]; then
      mutate_candidate $TMBR1
   fi

   CANDIDATES[${TMBR2}]="$CHILD2"
   let "TEMP = RANDOM % 100"
   if [ $TEMP -le $MUTATION_RATE ]; then
      mutate_candidate $TMBR2
   fi

#   echo ">>>>> $TMBR1 + $TMBR2   ===>  > ${CANDIDATES[${TMBR1}]} < + > ${CANDIDATES[${TMBR2}]} <"
}

     #####################################################################################
     # initialize() - does some set-up stuff to prepare for our testing
     #####################################################################################
initialize()
{
   printf "Target String:   >>> $TARGET_STRING <<< \n"
   TNDX=0
   while [ $TNDX -lt $LENGTH ]; do
      TCHAR=${TARGET_STRING:$TNDX:1}
      char2int "$TCHAR"
      TARGET_ARRAY[$TNDX]=$TVAL
      # printf " %3s" $TVAL
      let "TNDX += 1"
   done
   printf "\n"

   TMBR=0
   while [ $TMBR -lt $POOL_SIZE ]; do
      create_new_candidate
      CANDIDATES[${TMBR}]="$TSTRING"
      determine_fitness $TMBR
      let "TMBR += 1"
   done
}

##########################################################################################
# now we can get started...                                                              #
##########################################################################################
initialize

SUCCESS=0                                         # loop until we hit our target string...
while [ $SUCCESS -eq 0 ]; do
   # go through each of our candidates and give them a fitness score
   TMBR=0
   POPULATION_SCORE=0
   while [ $TMBR -lt $POOL_SIZE ]; do
      determine_fitness $TMBR
      let "POPULATION_SCORE += FITNESS[${TMBR}]"
      let "TMBR += 1"
   done

   sort_candidate_pool       # place our candidates into fitness-order

   if [ $SECONDS -gt $NUM_SECONDS ]; then
      display_prodigy
      generate_report
      echo ""
      exit
   fi

   # if any of our candidates is the target string we are done, report success
   if [ ${FITNESS[0]} -eq 0 ]; then
      SUCCESS=1
   else
      let "LAST_PARENT = POOL_SIZE - 1"  # all candidates can be parents
      TMBR=0
      while [ $TMBR -lt $LAST_PARENT ]; do
         # go through each of our candidates and see if they will be parents
         let "TEMP = RANDOM % 100"
         if [ $TEMP -le $REPRO_CHANCE ]; then     # if we are looking for love...
            let "TMBR2 = RANDOM % BEST_FITS"      # randomly pick one of the available parents
            if [ $TMBR -eq $TMBR2 ]; then         # we can't have a kid by ourselves
               if [ $TMBR -eq 0 ]; then           #    so use the best available candidate
                  TMBR2=1
               else
                  TMBR2=0
               fi
            fi
            create_offspring $TMBR $TMBR2         # now let's have those kids!
         fi
         let "TMBR += 1"
      done

      let "TEMP = RANDOM % 100"
      if [ $TEMP -le $RETURN_CHANCE ]; then
         # echo ">>>>> Bring back the prodigal son!"
         CANDIDATES[${LAST_PARENT}]="$BEST_MATCH" 
      else
         create_new_candidate
         CANDIDATES[${LAST_PARENT}]="$TSTRING"
         FITNESS[${LAST_PARENT}]=$BEST_VAL
      fi

      while [ $LAST_PARENT -gt $CHURN_RATE ]; do
         let "LAST_PARENT -= 1"
         create_new_candidate
         CANDIDATES[${LAST_PARENT}]="$TSTRING"
      done

      let "GENERATION += 1"          # increase the generation number
   fi
done

display_prodigy
printf "\n\n\nMatch found in Generation $GENERATION \n\n\n"
