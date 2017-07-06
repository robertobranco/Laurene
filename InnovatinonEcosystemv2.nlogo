;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Innovation Ecosystem ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;; breeds ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [entities entity]
breed [niches niche]

;;;;;;;;;;;;;;;;;;;;;; turtle variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

entities-own [

  ;; stores the scientific knowledge of the entity. It is a characteristic of Generators and Diffusers
  science-knowledge
  new-science-knowledge
  ;; lets the model know which entities have active scientific knowledge
  science?
  ;; stores the technological knowledge of the entity. It is a characteristic of Consumers and Diffusers
  tech-knowledge
  new-tech-knowledge
  ;; lets the  model know which entities have active technological knowledge
  technology?
  ;; stores the Hamming distance of the entity (currently just from one niche)
  fitness
  ;; stores the amount of resources kept by the entity
  resources
  ;; Stores the entity's reputation, given its resources and fitness in its niche
  reputation
  ;; does the entity assume a generator role in the ecosystem?
  generator?
  ;; does the entity assume a generator role in the ecosystem?
  consumer?
  ;; does the entity assume a generator role in the ecosystem?
  diffuser?
  ;; does the entity assume a generator role in the ecosystem?
  integrator?
  ;; entity's willingness to share knowledge with others
  willingness-to-share
  ;; entity's motivation to learn from others
  motivation-to-learn
  ;; entity's creation performance
  creation-performance

]

niches-own [

  ;; total-resources of a niche (put this on a slider in the future)
  niche-resources
  ;; stores the demand DNA of the niche
  niche-demand
  ;; it is the average fitness of the entities competing on the niche
  average-fitness

]


;;;;;;;;;;;;;;;;;;;;;;; globals ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [

 ;; holds counter value for which instruction is being displayed
 current-instruction
 ;; stores the niche-demand DNA for comparison
 niche-demand-now
 ;; it is the sum of the fitness of every entity competing on the niche
 total-fitness
 ;; agentset of possible partners for crossover
 possible-partners

]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; setup procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup

  clear-all
  ask patches [set pcolor black];
  set-default-shape entities "circle";

  ;; creates the entities and assigns them resources, a knowledge DNA and its role (s)
  create-entities number_of_entities [
    set size (initial_resources / 500)
    set color blue
    setxy random-xcor random-ycor

    ;; asks turtles to select their roles
    select-role

    ;; gives the entities its initial resources
    set resources initial_resources

    ;; *** gets all entities as consumers (temporary - for test purposes)
    ;;*** has to change as soon as there is a way for the non market entities to find resources on their own
    set consumer? true

  ]

  ;; *** issue - how to deal with more than one niche - resources only go to the fittest, how to display the colors (may be fit in one and not in the other) ***
  ;; creates the niches where entities will compete and assigns them a demand DNA (temporarily just one)
  create-niches 1 [
    set niche-demand n-values (knowledge / 2) [random 2]
    hide-turtle
    show niche-demand
  ]
  ;; resets the tick clock
  reset-ticks

  ;; *** just for testing - sets one superfit entity ***
  ;; ask one-of entities [set tech-knowledge [niche-demand] of one-of niches]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; go procedures   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  ;; implements the stop trigger
    if ticks >= stop_trigger [ stop ]


  ;; asks entities to assess their Hamming distance for fitness test (check algoritm for Hamming)
  ask entities [test-fitness]
  set total-fitness sum [fitness] of entities

  ;; gives the entities resources proportional to their fitness, and collects resources
  ask entities [calculate-resource]

  ;; stops the simulation if all the entities have died after calculating the resources
    if not any? entities [stop]

  ;; ask entities to look for partners and exchange knowledge
  ;; ask entities to create new knowledge
  ;; ask entities to convert knowledge
  ;; ask entities to update its own parameters (adapt)
  ;; generate graphics and output updates
  ;; create new entities to replace the dead from crossover of other fit entities and mutations
  ;; the impact of integrators on relations

  ;;ask entities [show choose-partner]
  ;;ask entities [show crossover]
  ask entities [
    set new-tech-knowledge crossover
    show new-tech-knowledge
  ]

  ask entities [set tech-knowledge new-tech-knowledge]

  tick

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; entities' procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to select-role

  ;; initializes the kind of knowledge possessed by the entities. The default is no knowledge
  set science? false
  set technology? false

  ;; randomly sets the role (s) an entity assumes in the ecosystem.
  ;; sets the type of knowledge the entity has according to its role
  ;; later it has to be more controllable, assigning a known proportion of each

  ;; does the entity assume a generator role in the ecosystem?
  set generator? one-of [true false]
  if generator? [set science? true]

  ;; does the entity assume a consumer role in the ecosystem?
  set consumer? one-of [true false]
  if consumer? [set technology? true]

  ;; does the entity assume a diffuser role in the ecosystem?
  ;; if the entity accumulates other role, it will retain the knowledge the other role confers, and maybe add another
  set diffuser? one-of [true false]
  if not science? [set science? one-of [true false]]
  if not technology? [set technology? one-of[true false]]

  ;; does the entity assume an integrator role in the ecosystem? Integrators don't need to have scientific or technological knowledge
  set integrator? one-of [true false]

  ;; selects the shape of the entity given its role in the ecosystem
  select-shape

  ;; randomly creates the scientific knowledge string
  ;; if the entity does not possess this kind of knowledge, the string is all 0's
  ifelse science? [
  set science-knowledge n-values (knowledge / 2)  [random 2]
  show science-knowledge
  ]
  [ set science-knowledge n-values (knowledge / 2) [0]
  ]

  ;; randomly creates the technological knowledge string
  ;; if the entity does not possess this kind of knowledge, the string is all 0's
  ifelse technology? [
  set tech-knowledge n-values (knowledge / 2) [random 2]
  show tech-knowledge
  ]
  [ set tech-knowledge n-values (knowledge / 2) [0]
  ]

end

;; evaluates the hamming distance between the niche's demand and the consumers tech-knowledge
to test-fitness

  set fitness 0
  set niche-demand-now [niche-demand] of one-of niches
  set fitness length remove false ( map [ [ a b ] -> a = b ]  tech-knowledge niche-demand-now )

;; alternate code for the hamming distance
;;  let counter 0
;;  foreach tech-knowledge [
;;      if item (counter) tech-knowledge = item (counter) niche-demand-now
;;      [set fitness fitness + 1]
;;       if counter < knowledge [set counter counter + 1]
;;      ]

  ;; sets the color of the entities based on its absolute fitness
  select-fitness-color

end

;; procedure to calculate how much must the entity receive from the market, and how much must it pay to live
;; also adjusts the size of the entity given the amount of its resources
to calculate-resource

    ;; gives an entity a share of the niche's resources proportional to its market share (relative fitness)
    set resources resources + (niche_resources * (fitness / total-fitness))

    ;; takes resources from the entity proportionally to its total amount of resources, respecting the minimum amount to stay alive
    ;; the amount necessary grows with the amount of resources the entity amasses (which is the growth of the entity)
    ;; the rate of the expense growth is given by the expense to live growth slider
    set resources resources - (minimum_resources_to_live + (resources * expense_to_live_growth))

    ;; sets the size of the entity given its accumulated amount of resources
    set-size-entity

    ;; kills the entity if it has no resources left
    if resources < 0 [ die ]

end


;; creates agentsets of possible partners who possess the same kind of knowledge possessed by the choosing entity
;; *** issue - something has to be done with the agentsets before it is closed. The lottery for an instance
to-report choose-partner

  ;; creates an agentset with entities possessing knowledge similar to the knowledge of the choosing entity
  ifelse science? and technology? [
    set possible-partners other entities with [science? or technology?]
    ]
    [ifelse science? [
      set possible-partners other entities with [science?]
      ]
      [if technology? [
        set possible-partners other entities with [technology?]
        ]
      ]
    ]

  ;; creates roulette that will select the partner from the agentset of suitable partners (Lottery Example model from Netlogo)
  ;; the method favours those with higher reputation and more resouces, but it doesnt rule anyone out.
  let pick random-float (sum [fitness] of possible-partners  + sum [resources] of possible-partners)
  let partner nobody
  ask possible-partners
    [ ;; if there's no winner yet...
      if partner = nobody
        [ ifelse (resources + fitness) > pick
            [ set partner self ]
            [ set pick pick - (resources + fitness) ] ] ]
  report partner

  ;; *** alternate code for simplicity
  ;; lottery example e comando 	rnd:weighted-one-of	rnd:weighted-one-of-list
  ;; The idea behind this procedure is a bit tricky to understand.
  ;; Basically we take the sum of the sizes of the turtles, and
  ;; that's how many "tickets" we have in our lottery.  Then we pick
  ;; a random "ticket" (a random number).  Then we step through the
  ;; shorter code option - see netlogo online manual
  ;;ask rnd:weighted-one-of entities with science? [ resources + fitness ] [set partner self]

end

;; crossover procedure from simple genetic algorithm model
;; This reporter performs one-point crossover on two lists of bits.
;; That is, it chooses a random location for a splitting point.
;; Then it reports two new lists, using that splitting point,
;; by combining the first part of bits1 with the second part of bits2
;; and the first part of bits2 with the second part of bits1;
;; it puts together the first part of one list with the second part of
;; the other.
;; In this model, if we consider unidirectional exchanges of knowledge, only
;; one of the answers has to be chosen to represent the new knowledge DNA of
;; the receiver entity


to-report crossover

  ;; chooses a suitable partner to be the emitter
  let partner choose-partner
  ;; bits1 is the tech-knowledge of the receiver
  let bits1 [tech-knowledge] of  self
  ;; bits2 is the tech-knowledge of the emitter
  let bits2 [tech-knowledge] of partner

  let split-point 1 + random (length bits1 - 1)
  report item one-of [0 1]
    list (sentence (sublist bits1 0 split-point)
                   (sublist bits2 split-point length bits2))
         (sentence (sublist bits2 0 split-point)
                   (sublist bits1 split-point length bits1))

end

;; mutation procedure from simple genetic algorithm model
;; This procedure causes random mutations to occur in a solution's bits.
;; The probability that each bit will be flipped is controlled by the
;; MUTATION-RATE slider.
;; to mutate   ;; turtle procedure
;;   set bits map [ [b] ->
;;     ifelse-value (random-float 100.0 < mutation-rate)
;;       [ 1 - b ]
;;       [ b ]
;;   ] bits
;; end

;; The Hamming distance between two bit sequences is the fraction
;; of positions at which the two sequences have different values.
;; We use MAP to run down the lists comparing for equality, then
;; we use LENGTH and REMOVE to count the number of inequalities.
;; to-report hamming-distance [bits1 bits2]
;;   report (length remove true (map [ [b1 b2] -> b1 = b2 ] bits1 bits2)) / world-width
;; end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; niche's procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mutation

;; niche swap

;; niche learning from introduced products (crossover with consumers)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; GUI procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sets the shape of the entities according to their role
to select-shape

    ;; star for generators
    if generator? and not consumer? and not diffuser? and not integrator? [set shape "star"]
    ;; square for consumers
    if not generator? and consumer? and not diffuser? and not integrator? [set shape "square"]
    ;; triangle for diffusers
    if not generator? and not consumer? and diffuser? and not integrator? [set shape "triangle"]
    ;; pentagon for integrators
    if not generator? and not consumer? and not diffuser? and integrator? [set shape "pentagon"]
    ;; circle remains for hybrids, as it is the default shape

end

;; also assigns a color to the entity given its absolute fitness (an option would be to code this to evaluate if it is earning enough to live or not)
to select-fitness-color

  ifelse color_update_rule = "fitness" [
    ;; implements the color updating by absolute fitness
    ifelse (fitness / (knowledge / 2 )) > 0.67 [ set color green]
      [ ifelse (fitness / (knowledge / 2 )) > 0.33 [ set color yellow]
      [ set color red] ]
    ]
    ;; implements the color updating by survivability, the amount of iterations the entity would
    ;; be able to survive without receiving any resources
    ;; of course, it can live longer if it keeps gathering resources from the environment
  [ ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 10) [ set color green ]
    [ ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 5) [ set color yellow ]
      [set color red]
    ]
  ]

end

;; sets the size of the entity proportional to its resources, related to the amount of periods it could live without receiving resources
to set-size-entity

     set size resources / (minimum_resources_to_live + (resources * expense_to_live_growth))

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; (modelo DNA Protein Synthesis)
;;;;;;;;;;;;;;;;;;;;;; instructions for players ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; presents the number of the instruction being read, and sugests the press setup if none is displayed
to-report current-instruction-label
  report ifelse-value (current-instruction = 0)
    [ "press setup" ]
    [ (word current-instruction " of " length instructions) ]
end

;; goes to next instruction on the list
to next-instruction
  show-instruction current-instruction + 1
end

;; goes to previos instruction on the list
to previous-instruction
  show-instruction current-instruction - 1
end

;; prints the selected instruction
to show-instruction [ i ]
  if i >= 1 and i <= length instructions [
    set current-instruction i
    clear-output
    foreach item (current-instruction - 1) instructions output-print
  ]
end

;; instrutcions
to-report instructions
  report [
    [
     "You will be simulating an innovation"
     "ecosystem based on knowledge flows."
     "The shapes of the entities denote"
     "their role in the ecosystem, and their"
     "color denotes their absolute fitness or"
     "their ability to stay alive for several"
     "periods"
    ]
    [
     "When you press SETUP, a population of"
     "entities is randomly created."
     "Their roles and knowledge DNA's are"
     "randomly created."
     "Scientific knowledge and technological"
     "knowledge is assigned according to the"
     "entities roles in the ecosystem."

    ]
    [
     "Choose the amount of entities you want"
     "in the ecosystem by sliding the"
     "number_of_entities slider"
     "Choose the number of market niches "
     "where the entities will compete by"
     "sliding the number_of_niches slider"
    ]
    [
      "Choose the initial amount of resources"
      "the entities possesses by sliding the"
      "initial_resources slider"
      "Choose the size of the markets by sliding"
      "niche_resources slider"
    ]
    [
      "Choose the amount of resources that are"
      "available at a market by sliding the"
      "niche_resources"
      "Choose minimum amount of resources to live"
      "by sliding the minimum_resources_to_live"
      "slider"
      "Choose how much do the resources necessary"
      " to remain in the market grow as the entity"
      " grows by sliding the"
      "expense_to_live_growth slider "
    ]
    [
     "The chooser  color_update_rule chooses how"
     "the colors of the entities will be updated"
     "Choosing fitness the model will color the "
     "entities according to their absolute fitness,"
     " being red up to 33% fitness, yellow up to "
     "67% fitness and green up to 100% fitness"
     "Choosing survivability will update the colors"
     " given the number of iterations the entity "
     "would be able to live without receiving "
     "any resources, being red for less than 5"
     "yellow for less than 10, and green for more"
     "than 10 iterations."
     "of course it can live longer if it keeps"
     "gathering resources from the environment"
     "but would be in trouble if competition "
     "increased or if its fitness dropped."
    ]
    [
     "The stop_trigger tells the model after how"
     "many iterations it should stop, so it will"
     "be easier to compare the results of multiple"
     "runs"
     "There is a button go for infinite loop until"
     "the stop_trigger (if defined) is reached"
     "and a button go for manual single iterations"
    ]


  ]
end

; Copyright 2017 José Roberto Branco Ramos Filho
; See info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
372
10
809
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
27
10
82
57
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
27
92
211
125
number_of_entities
number_of_entities
1
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
27
59
211
92
Knowledge
Knowledge
2
100
100.0
2
1
NIL
HORIZONTAL

SLIDER
27
159
211
192
initial_resources
initial_resources
1
1000
1000.0
1
1
NIL
HORIZONTAL

BUTTON
87
10
145
57
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
27
331
368
514
12

BUTTON
27
297
205
330
Previous Instruction
previous-instruction
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
203
297
367
330
Next Instruction
next-instruction
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
27
515
113
560
Instruction #
current-instruction-label
17
1
11

SLIDER
27
126
211
159
number_of_niches
number_of_niches
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
27
192
211
225
niche_resources
niche_resources
0
20000
10000.0
1000
1
NIL
HORIZONTAL

SLIDER
27
225
211
258
minimum_resources_to_live
minimum_resources_to_live
1
1000
501.0
100
1
NIL
HORIZONTAL

SLIDER
27
258
211
291
expense_to_live_growth
expense_to_live_growth
0
1
0.05
0.05
1
NIL
HORIZONTAL

PLOT
813
11
1013
161
Fitness of entities histogram
Entity's fitness
Entities
0.0
100.0
0.0
10.0
false
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [fitness] of entities"

PLOT
1014
11
1214
161
Entities' resources histogram
Resources posessed
Entities
0.0
50000.0
0.0
10.0
false
false
"" ""
PENS
"default" 1000.0 1 -13840069 true "" "histogram [resources] of entities"

PLOT
813
160
1013
310
Fitness average
Ticks
Average Fitness
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Average fitness" 1.0 0 -2674135 true "" "plot (sum [fitness] of entities) / (count entities)"

PLOT
1013
161
1213
311
Average resources
Ticks
Average resources
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Average resources" 1.0 0 -14070903 true "" "plot (sum [resources] of entities) / (count entities)"

MONITOR
812
356
1012
401
Maximum fitness
max [fitness] of entities
17
1
11

MONITOR
1014
356
1213
401
Maximum resources accumulated
max [resources] of entities
2
1
11

CHOOSER
215
73
353
118
color_update_rule
color_update_rule
"fitness" "survivability"
1

MONITOR
812
311
1012
356
Std deviation of fitness
standard-deviation [fitness] of entities
2
1
11

MONITOR
1013
310
1213
355
Std deviation of resources
standard-deviation [resources] of entities
2
1
11

BUTTON
150
10
210
58
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
814
402
1013
447
Minimum fitness
min [fitness] of entities
2
1
11

MONITOR
1014
401
1212
446
NIL
min [resources] of entities
2
1
11

INPUTBOX
213
10
353
70
stop_trigger
2000.0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

Innovation Ecosystem Model based on Knowledge Flows

It observes the diffusion of knowledge in a community of entitities, given the fact that each of them has a knowledge "DNA", a role towards knowledge, and individual characteristics towards learning and sharing that evolve given the entities past failures and successes.

These entitities are located in an environment that may spur or hinder the efforts, affecting the agents willingness to share knowledge, motivation to learn, and trust in each other.

The mentioned roles are:

• Generators: those who generate new scientific/ technological knowledge. Create inventions, or further the state of the art;
• Diffusers: those who absorb, store, process knowledge created by other entities and transmit it to other organizations or people, without significantly furthering the state of the art or providing the society products that embed the knowledge. They may recode, translate and perform other transformations to ease its transfer and make it accessible to entities that lack the absorption capacity to receive it directly from generators;
• Integrators: these entities connect other entities. They create relationships, introduce and establish trust between partners, disseminate cultural values, and create views of how the other entities could interact, although not handling knowledge itself;
• Consumers: those who apply new knowledge into the products, services, processes, methods that are related to their main activities. Through these entities the effects of the new knowledge reach customers and society. They are the innovators in the sense [12] meant.


## HOW IT WORKS


## HOW TO USE IT

Set the number of entities.
Set the number of niches where they will compete.
Set the amount of resources the niches have to distribute.
Set the initial amount of resources each entity has to get by.
Click on the Setup button.
Click on the Go button.


## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Ramos Filho, J. R. B., Okada, L. M., Lima, C. P. (2017).  NetLogo Innovation Ecosystem Based on Knowledge Flows Model. Programa de Pós Graduação Sociedade, Natureza e Desenvolvimento, Universidade Federal do Oeste do Pará, Santarém, PA, Brasil.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
