;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Innovation Ecosystem ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extensions [table]

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
  ;; entity's performance in creating oportunities to create new knowledge
  creation-performance
  ;; entity's performance in creating oportunities to develop science into technology
  development-performance
  ;; lets the model know if the agent performed crossover
  crossover?
  ;; lets the model know if the agent performed mutation
  mutation?
  ;; lets the model know if the agent performed development of science knowledge into technological knowledge
  development?
  ;; lets the model know if the agent shared knowledge as the emitter
  emitted?
  ;; lets the model know if the mutation attempt by a generator was successful
  mutated?
  ;; lets the model know if the integrator attempted to integrate
  integrated?
  ;; lets the model know if the interaction of an agent is ocurring through an integrator
  integration?
  ;; entities memory of past interactions with other agents
  interaction-memory

]

niches-own [

  ;; total-resources of a niche (put this on a slider in the future)
  niche-resources
  ;; stores the demand DNA of the niche
  niche-demand

]


;;;;;;;;;;;;;;;;;;;;;;; globals ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [

 ;; holds counter value for which instruction is being displayed
 current-instruction
 ;; stores the niche-demand DNA for comparison
 niche-demand-now
 ;; agentset of possible partners for crossover
 possible-partners
 ;; seed used to generate random-numbers
 my-seed
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; setup procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup

  clear-all

  ;; Makes the seed that will create the random numbers in the model known, making it repeatable
  ;; The seed may be choosen by the user, or randomly chosen by the model
  ;; The seed being used will be displayed in the interface in the my-seed-repeat input.
  ifelse repeat_simulation? [

    ;; Takes the seed stored in the my-seed-repeat from the last simulation / user intervention during simulation
    random-seed my-seed-repeat

  ][
    ifelse set_input_seed? [

      ;; Use a seed entered by the user
      let suitable-seed? false
      while [not suitable-seed?] [

        set my-seed user-input "Enter a random seed (an integer):"

        ;; Tries to set my-seed from the input. If it is not possible, does nothing
        carefully [ set my-seed read-from-string my-seed ] [ ]

        ;; Tests the value from my-seed. If it is suitable (number and integer), sets the random-seed
        ;; If not, asks for a new one
        ifelse is-number? my-seed and round my-seed = my-seed [
          random-seed my-seed ;; use the new seed
          output-print word "User-entered seed: " my-seed  ;; print it out
          set my-seed-repeat my-seed
          set suitable-seed? true
        ][
          user-message "Please enter an integer."
        ]
      ]

    ][
      ;; Use a seed created by the NEW-SEED reporter
      set my-seed new-seed            ;; generate a new seed
      output-print word "Generated seed: " my-seed  ;; print it out
      random-seed my-seed             ;; use the new seed
      ;; Displays the new seed in the my-seed-repeat input
      set my-seed-repeat my-seed
    ]
  ]

  ask patches [set pcolor black];
  set-default-shape entities "circle";

  ;; creates the niches where entities will compete and assigns them a demand DNA
  ;; has to be created before the entities, so they can assess their fitness from the start

  create-niches 1 [

    ;; set the niche demand randomly
    ;; set niche-demand n-values (knowledge / 2) [random 2]

    ;; sets the niche demand as a full specification of what would be desirable, or all ones
    set niche-demand n-values (knowledge / 2) [1]
    hide-turtle
    show niche-demand
  ]

  ifelse random_ent_creation? [

    ;; creates random amounts of each kind of entity and assigns them resources, a knowledge DNA and others
    create-entities number_of_entities [

      ;; asks turtles to select their roles
      select-role
      set-entity-parameters
      set color blue

    ]
  ][
    ;; creates the selected amount of each kind of entity and assigns them resources, a knowledge DNA and others
    create-entities number_of_generators [

      set generator? true
      set consumer? false
      set diffuser? false
      set integrator? false

      set-entity-parameters
      set color orange
    ]

    create-entities number_of_consumers [

      set generator? false
      set consumer? true
      set diffuser? false
      set integrator? false

      set-entity-parameters
      set color orange
    ]

    create-entities number_of_diffusers [

      set generator? false
      set consumer? false
      set diffuser? true
      set integrator? false

      set-entity-parameters
      set color orange
      ]

    create-entities number_of_integrators [

      set generator? false
      set consumer? false
      set diffuser? false
      set integrator? true

      set-entity-parameters
      set color orange
    ]

    create-entities number_of_cons_gen [

      set generator? true
      set consumer? true
      set diffuser? false
      set integrator? false

      set-entity-parameters
      set color orange
    ]

    create-entities number_of_gen_dif [

      set generator? true
      set consumer? false
      set diffuser? true
      set integrator? false


      set-entity-parameters
      set color orange

    ]

  set number_of_entities (number_of_generators + number_of_consumers + number_of_integrators + number_of_diffusers + number_of_cons_gen + number_of_gen_dif)

  ]

  ;; resets the tick clock
  reset-ticks

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; go procedures   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  ;; implements the stop trigger
  if ticks >= stop_trigger [ stop ]

  ;; clears the links from previous iteration to keep a clean interface
  ask links [die]

  ;; asks entities to assess their Hamming distance for fitness test (check algoritm for Hamming)
  ask entities [test-fitness]

  ;; gives the entities resources proportional to their fitness, and collects resources
  ask entities [calculate-resource]

  ;; replaces dead entities with new startups, keeping the competition high
  ;; has to be called after calculate-resources, to avoid choosing dead parents
  if (count entities) !=  number_of_entities and startups? [
    spawn-startup (number_of_entities - (count entities))
  ]

  ;; stops the simulation if all the entities have died after calculating the resources
  if not any? entities [
    print "There are no entities left"
    stop
  ]
  if count entities = 1 [
    print "There is only one entity left"
    stop
  ]

  if count entities with [science? or technology?] = 0 [
    print "There are no knowledge entities left"
    stop
  ]

  ;; *** to do list
  ;; ask entities to update its own parameters (adapt)
  ;; the impact of environment in relations

  ;; knowledge activities inside the entities

  ;; ask generators to perform research, in other words, mutate knowledge
  ;; *** has to be called before the call to interact, as it may alter newly developed science
  ask entities with [generator?] [

    generate

  ]

  ;; asks entities with scientific and technological knowledge to develop science into technology
  ;; *** has to be called before interact to prevent the altering of newly developed knowledge
  ask entities with [science? and technology?] [

    develop

  ]

  ;; knowledge activities with other entities

  ;; asks integrators to facilitate the interaction and crossover between two entities
  ask entities with [integrator?] [

    integrate

  ]

  ;; ask entities with some kind of knowledge  to look for partners and possibly, to crossover
  ;; *** has to be called after the call for development, to prevent the destruction of newly developed knowledge, unless
  ;; it is the intention to allow entities to perform more than one activity per iteration - in that case some of the learning may be overwritten
  ;; the crossover? flag is set by the interact procedure after both entities have agreed to interact
  ;; since integrated entities also perform interact, it is possible that an entity has already performed crossover when the code gets to this point
  ask entities with [science? or technology?] [
    if resources > cost_of_crossover and not development? and not mutation? and not crossover? [

      interact

    ]
  ]

  ;; ask entities to update their knowledge given the actions performed on the iteration
  ask entities [
    set science-knowledge new-science-knowledge
    set tech-knowledge new-tech-knowledge
  ]

  tick

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; external sources procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; it has to be on the same directory as the .nlogo model
;; _includes [ .nls]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; entities' procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to evaluate-crossover

end





to spawn-startup [number-of-startups]

repeat number-of-startups[
  create-entities 1 [

    set generator? false
    ;; set generator? one-of [true false] ;; if a chance of creating a generator consumer is desired
    set consumer? true
    set diffuser? false
    set integrator? false

    ;; assigns all other variables, as well as a random tech-knowledge and science-knowledge DNA
    set-entity-parameters
    set color cyan
    set shape "turtle"
    print "called set entity parameters"

    ;; chooses one of the other entities to be a parent of the new startup
    let parent1 choose-partner

    ;; chooses the second parent with replacement
    let parent2 choose-partner
    show parent1
    show parent2

    if parent1 != nobody and parent2 != nobody [

      print "Parents 1 and 2 successfuly selected"

      ;; the code ignores the cases where the chosen parents do not have matching knowledge
      ;; that is only a possibility when the startup is a generator-consumer, if one parent has only science?  and the other has only technology?
      ;; in that case, the startup will remain with the set-entity-parameters randomly assigned knowledge
      ;; if none gets executed (both parent1 and parent2 = nobody) then the startup uses the knowledge DNA assigned by
      ;; the set-entity-parameters procedure.
      ;; *** code can be writen so that the startup would fetch the scientific knowledge from one and the tech knowledge from the other

      ;; if the new startup has both kinds of knowledge, and so do the chosen parents
      ifelse science? and technology? and [science? and technology?] of parent1 and [science? and technology?] of parent2 [

        ;; bits1 is the science-knowledge of the parent 1
        let bits1 [science-knowledge] of parent1
        ;; bits2 is the science-knowledge of the parent 2
        let bits2 [science-knowledge] of parent2
        set new-science-knowledge crossover bits1 bits2

        ;; also performs a mutation in science knowledge to create the startup
        set new-science-knowledge mutate new-science-knowledge

        ;; bits1 is the tech-knowledge of the parent 1
        set bits1 [tech-knowledge] of parent1
        ;; bits2 is the tech-knowledge of the parent 2
        set bits2 [tech-knowledge] of parent2
        set new-tech-knowledge crossover bits1 bits2

        ;; also performs a mutation in technological knowledge to create the startup
        set new-tech-knowledge mutate new-tech-knowledge

      ][;; if the startup and both parents have only scientific knowledge in commmon

        ifelse science? and [science?] of parent1 and [science?] of parent2 [
          ;; bits1 is the science-knowledge of the parent 1
          let bits1 [science-knowledge] of parent1
          ;; bits2 is the science-knowledge of the parent 2
          let bits2 [science-knowledge] of parent2
          set new-science-knowledge crossover bits1 bits2

          ;; also performs a mutation in science knowledge
          set new-science-knowledge mutate new-science-knowledge

        ][;; if the startup and both parents have only technological knowledge in commmon

          if technology? and [technology?] of parent1 and [technology?] of parent2 [
            ;; bits1 is the tech-knowledge of the parent 1
            let bits1 [tech-knowledge] of parent1
            ;; bits2 is the tech-knowledge of the emitter
            let bits2 [tech-knowledge] of parent2
            set new-tech-knowledge crossover bits1 bits2

            ;; also performs a mutation in technological knowledge
            set new-tech-knowledge mutate new-tech-knowledge

          ]
        ]
      ]
    ]

    ;; finishes by making both new-knowledge and knowledge variables equal, as the entity is starting its life and has not yet learned
    set science-knowledge new-science-knowledge
    set tech-knowledge new-tech-knowledge
  ]
]

end


to develop

  if resources > cost_of_development [
      if random-float 1 < development-performance [

        ;;using new-tech-knowledge instead of tech-knowledge allows several knowledge activities to be performed without loosing the notion of paralelism
        ;; although some of the learning of the previous activity may be altered
        set new-tech-knowledge crossover new-tech-knowledge new-science-knowledge
        ;; flags the model that internal crossover between scientific and technologica knowledge (development) was attempted
        set development? true
      ]
    ]

end

to generate

  if random-float 1 < creation-performance [
      if resources > cost_of_mutation [
        set mutation? true
        let new-science-knowledge1 new-science-knowledge
        set new-science-knowledge mutate new-science-knowledge
        if length ( remove true ( map [ [a b] -> a = b ] new-science-knowledge1 new-science-knowledge )  ) > 0 [
          set mutated? true
        ]
      ]
    ]
end

to set-entity-parameters

  ;; sets knowledge as false by default, to be changed according to the roles
  set science? false
  set technology? false

  ;; sets the type of knowledge the entity has according to its role

  if generator? [set science? true]
  if consumer? [set technology? true]
  if diffuser? [
    if not science? [set science? one-of [true false]]
    if not technology? [set technology? one-of [true false]]

    ;; If, by any chance, the diffuser has no knowledge assignment, repeat the random assignment
    while [ not science? and not technology?] [
      if not science? [set science? one-of [true false]]
      if not technology? [set technology? one-of [true false]]
    ]
  ]

  ;; gives the entities its initial resources
  set resources initial_resources
  set size (initial_resources / 500)
  setxy random-xcor random-ycor

  ;; sets the individual characteristics of the entities that will influence how often they interact with others
  ;; this is done as a normal distribution
  set willingness-to-share random-normal willingness_to_share std_dev_willingness
  set motivation-to-learn random-normal motivation_to_learn std_dev_motivation
  set creation-performance random-normal creation_performance std_dev_creation_performance
  set development-performance random-normal development_performance std_dev_development_performance

  ;; tells the model they the entities have not performed any of these actions yet
  ;; Flags that impact on the payment of resources and measurement of activities
  set crossover? false
  set mutation? false
  set integration? false
  set development? false

  ;; Flags that impact on the receiving of resources and measurement of activities
  set emitted? false
  set mutated? false
  set integrated? false

  ;; creates a table to implement the interaction memory
  set interaction-memory table:make

  ;; selects the shape of the entity given its role in the ecosystem
  select-shape
  create-knowledge-DNA
  test-fitness

end

;; creates a superfit entity, perhaps an entity that comes from another market
to create-super-generator


  create-entities 1 [

    set generator? true
    set consumer? false
    set diffuser? false
    set integrator? false

    set-entity-parameters

    ;; sets the creation performance to 0 and the motivation to learn to 0 to preserve the super-fitness
    if not super_share? [
      set creation-performance 0
      set motivation-to-learn 0
    ]

    ;; creates a perfect match to the market demand
    set science-knowledge [niche-demand] of one-of niches
    set new-science-knowledge science-knowledge

    ;; assigns the supercompetitor the best fitness score possible from the start
    test-fitness
    set color magenta
    set shape "star 2"

  ]

end

to create-super-competitor


  create-entities 1 [

    set generator? false
    set consumer? true
    set diffuser? false
    set integrator? false

    set-entity-parameters

    ;; sets the motivation to learn and willingness to share to 0 to preserve the competitivity of the super competitor
    if not super_share? [
      set willingness-to-share 0
      set motivation-to-learn 0
    ]

    ;; creates a perfect match to the market demand
    set tech-knowledge [niche-demand] of one-of niches
    set new-tech-knowledge tech-knowledge

    ;; assigns the supercompetitor the best fitness score possible from the start
    test-fitness
    set color magenta
    set shape "square 2"
  ]

end


;; creates a superfit diffuser. Different from the other super entities, this one assumes
to create-super-diffuser


  create-entities 1 [

    set generator? false
    set consumer? false
    set diffuser? true
    set integrator? false

    set-entity-parameters

    ;; a super diffuser gets maximum efficiency when sharing knowledge
    if not super_share? [
      set willingness-to-share 1
      set motivation-to-learn 0
    ]

    ;; creates a perfect match to the market demand
    set tech-knowledge [niche-demand] of one-of niches
    set new-tech-knowledge tech-knowledge
    set science-knowledge tech-knowledge
    set new-science-knowledge science-knowledge

    ;; assigns the supercompetitor the best fitness score possible from the start
    test-fitness
    set color magenta
    set shape "triangle 2"
  ]

end


to select-role

  ;; randomly sets the role (s) an entity assumes in the ecosystem.
  ;; sets the type of knowledge the entity has according to its role
  ;; later it has to be more controllable, assigning a known proportion of each

  ;; does the entity assume a GENERATOR role in the ecosystem?
  set generator? one-of [true false]

  ;; does the entity assume a CONSUMER role in the ecosystem?
  set consumer? one-of [true false]

  ;; does the entity assume a DIFFUSER role in the ecosystem?
  ;; if the entity accumulates other role, it will retain the knowledge the other role confers, and maybe add another
  set diffuser? one-of [true false]

  ;; does the entity assume an INTEGRATOR role in the ecosystem? Integrators don't need to have scientific or technological knowledge
  set integrator? one-of [true false]

  ;; The code above randomly assigns roles, and they may be cumulative.
  ;; If any entity remains without a role in the ecosystem, it will be turned into a CONSUMER
  if not generator? and not consumer? and not diffuser?  and not integrator? [ set consumer? true ]

end

to create-knowledge-DNA
  ;; randomly creates the scientific knowledge string
  ;; if the entity does not possess this kind of knowledge, the string is all 0's
  ;; it also initializes the new-science-knowledge
  ifelse science? [
  set science-knowledge n-values (knowledge / 2)  [random 2]
  set new-science-knowledge science-knowledge
  ]
  [ set science-knowledge n-values (knowledge / 2) [0]
    set new-science-knowledge science-knowledge
  ]

  ;; randomly creates the technological knowledge string
  ;; if the entity does not possess this kind of knowledge, the string is all 0's
  ;; it also initializes the new-tech-knowledge
  ifelse technology? [
  set tech-knowledge n-values (knowledge / 2) [random 2]
  set new-tech-knowledge tech-knowledge
  ]
  [ set tech-knowledge n-values (knowledge / 2) [0]
    set new-tech-knowledge tech-knowledge
  ]

end

;; evaluates the hamming distance between the niche's demand and the consumers tech-knowledge

to test-fitness

  set fitness 0
  set niche-demand-now [niche-demand] of one-of niches
  let fitness1 0
  let fitness2 0
  set fitness1 length remove false ( map [ [ a b ] -> a = b ]  tech-knowledge niche-demand-now )
  set fitness2 length remove false ( map [ [ a b ] -> a = b ]  science-knowledge niche-demand-now )
  set fitness max (list fitness1 fitness2)

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
;; *** create options to award resources to each role

to calculate-resource

  ;; Awards the entities resources based on their actions / fitness

  ;; gives CONSUMER entities a share of the niche's resources proportional to its market share (relative fitness)
  ;; the relative fitness is calculated of the fitness of entities who compete for market share (CONSUMERS of knowledge)
  if consumer? [
    set resources resources + (niche_resources * (fitness / (sum [fitness] of entities with [consumer?])))
    if emitted? [
      set resources resources + (cost_of_crossover / 2)
      set emitted? false
    ]
  ]

  ;;******************* new function for resources of non market entities

  ;; Gives non market entities the minimum resources to live, to keep them always alive
  ;; The entities will receive extra resources if they suceed in sharing resources, generating new knowledge
  if not consumer? [

    if emitted? [
      set resources resources + (cost_of_crossover / 2)
      set emitted? false
    ]

   ;; if the mutation is well suceeded, the generator has the budget renewed.
    if mutated? [
      set resources resources + (2 * cost_of_mutation)
      set mutated? false
    ]
  ]


  ;;*******************************old code for resources of non market entities


  ;; gives GENERATORs a fixed budget every iteration, as well if they shared information
  ;; if generator? and not consumer? [
  ;;   set resources resources + (minimum_resources_to_live)
  ;;   if emitted? [
  ;;     set resources resources + (cost_of_crossover / 2)
  ;;     set emitted? false
  ;;   ]
  ;;
  ;;   if the mutation is well suceeded, the generator has the budget renewed.
  ;;   if mutated? [
  ;;     set resources resources + (2 * cost_of_mutation)
  ;;     set mutated? false
  ;;    ]
  ;; ]

  ;; gives DIFFUSERs a fixed budget every iteration, as well if they shared information
  ;; this assumes publicly funded diffusers
  ;; if diffuser? and not consumer? [
  ;;   set resources resources + initial_resources
  ;;   if emitted? [
  ;;     set resources resources + (cost_of_crossover / 2)
  ;;     set emitted? false
  ;;   ]
  ;; ]

  ;; gives pure INTEGRATORs a fixed budget every iteration
  ;; if integrator? and not consumer? [
  ;; set resources resources + minimum_resources_to_live
  ;; ]
  ;;********************************************************************************************

    ;; takes resources from the entity proportionally to its total amount of resources, respecting the minimum amount to stay alive
    ;; the amount necessary grows with the amount of resources the entity amasses (which is the growth of the entity)
    ;; the rate of the expense growth is given by the expense to live growth slider

  if consumer? [
    set resources resources - (minimum_resources_to_live + (resources * expense_to_live_growth))
  ]

  ;; Collects resources for the attempts of action
  ;; if the entity attempted to crossover, collect its cost
  if crossover? [
    set resources resources - cost_of_crossover
    set crossover? false
  ]

  ;; if the entity attempted to mutate, collect its cost
  if mutation? [
    set resources resources - cost_of_mutation
    set mutation? false
  ]

  ;; if the entity attempted to convert scientific knowledge into technological knowledge, collect its cost
  if development? [
    set resources resources - cost_of_development
    set development? false
  ]

  ;; Resets the integration attempt counter
  set integrated? false
  set integration? false

  ;; sets the size of the entity given its accumulated amount of resources
  set-size-entity

  ;; kills the entity if it has no resources left
  if resources < 0 [
    die
  ]

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

  ;; sums the fitness and resources of all possible partners to perform the normalization
  let total-fitness sum [fitness] of possible-partners
  let total-resources sum [resources] of possible-partners

  ;; this represents the sum of 100% of the normalized reputation and 100% of the normalized resources
  ;; but with less computational cost
  let pick random-float (1 + 1)
  let partner nobody
  ask possible-partners [
    ;; if there's no winner yet...
    if partner = nobody [
      ;; gives the chance of the entity given the sum of its normalized resources and normalized fitness
      ;; if there is a memory of having interacted with that entity in the past, it also boosts the chances of the agent
      ;; to be selected. The myself command uses the interaction-memory of the entity who is calling the choose-partner procedure
      ifelse table:has-key? [interaction-memory] of myself who [

        ifelse ((resources / total-resources) + (fitness / total-fitness) + (table:get [interaction-memory] of myself who)) > pick [
          set partner self
        ]
        [
          set pick pick - ((resources / total-resources) + (fitness / total-fitness))
        ]
      ][
        ifelse ((resources / total-resources) + (fitness / total-fitness)) > pick [
          set partner self
        ]
        [
          set pick pick - ((resources / total-resources) + (fitness / total-fitness))
        ]
        ]



    ]
  ]

;;  old non normalized code
;;  let pick random-float (sum [fitness] of possible-partners  + sum [resources] of possible-partners)
;;  let partner nobody
;;  ask possible-partners [
    ;; if there's no winner yet...
;;    if partner = nobody [
;;      ifelse (resources + (fitness)) > pick [
;;        set partner self
;;      ]
;;      [
;;       set pick pick - (resources + (fitness))
;;      ]
;;    ]
;;  ]

  report partner

  ;; *** alternate code for simplicity
  ;; lottery example commands	rnd:weighted-one-of	rnd:weighted-one-of-list
  ;; The idea behind this procedure is a bit tricky to understand.
  ;; Basically we take the sum of the sizes of the turtles, and that's how many "tickets" we have in our lottery.  Then we pick
  ;; a random "ticket" (a random number).  Then we step through the shorter code option - see netlogo online manual
  ;;ask rnd:weighted-one-of entities with science? [ resources + fitness ] [set partner self]

end

 ;; This procedure implements the attempt to interact with other entities
 ;; it will call procedures so select suitable partners, and from this pool, to select one
 ;; will analyze what kind of knowledge can be used for crossover and call the operation
 ;; it will then store the result in the new-knowledge variable, which will be used to update the
 ;; entity's knowledge at the end of the iteration.
 ;; it cannot update it because it would tamper with the fitness evaluation performed by other entities
 ;; before the run is done.

to interact

  ;; given the receiver's motivation to learn
  ;; chooses a suitable partner to be the emitter
  ;; If the interaction is intermediated by an integrator, there is a receiver's motivation-to-learn boost, increasing the chance of interaction

  let motivation-to-learn-actual 0
  let willingness-to-share-actual 0
  let receiver self

  ;; if this interaction is happening through an integrator, boos the motivation to learn
  ifelse integration? [
    ;; uses the integration_boost from the slider in the interface
    set motivation-to-learn-actual (motivation-to-learn + integration_boost)
  ]
  [
    set motivation-to-learn-actual motivation-to-learn
  ]

  ;; if the receiver decides, given its motivation (boosted or not) to interact and it has resources, look for partner
  ifelse (random-float 1 < motivation-to-learn-actual) and (resources > cost_of_crossover) [
    let partner choose-partner

    ;; if a emitter partner is found and the interaction is happening through an integrator, boost its willingness to share
    if partner != nobody [
      ifelse integration? [
        set willingness-to-share-actual ([willingness-to-share] of partner + integration_boost)
      ][
        set willingness-to-share-actual [willingness-to-share] of partner
      ]

      ;; adds to the willingness to share of the chosen partner the interaction memory the partner has of the receiver
      if (table:has-key? [interaction-memory] of partner [who] of receiver) [
        set willingness-to-share-actual (willingness-to-share-actual + table:get [interaction-memory] of partner [who] of receiver )
      ]
    ]

    ;; given the partners willingness to share (boosted or not), begin crossover
    ifelse partner != nobody and (random-float 1 < willingness-to-share-actual) [
      ;;  asks the partner to create a directional link to the receiver
      ask partner [
        create-link-to receiver
        set emitted? true
      ]

      set crossover? true

      ;; *** decide whether an interaction between entities with both kinds of knowledge results in changes in both
      ;; kinds of knowledge
      ;; if both the entity (receiver) and the partner (emitter) possess scientific and technological knowledge
      ifelse science? and technology? and [science? and technology?] of partner [

        ;; bits1 is the science-knowledge of the receiver
        let bits1 science-knowledge
        ;; bits2 is the science-knowledge of the emitter
        let bits2 [science-knowledge] of partner
        set new-science-knowledge crossover bits1 bits2

        ;; after learning has been done, also performs a mutation in science knowledge, following traditional genetic algorithms
        ;;let new-science-knowledge1 new-science-knowledge ;;*** used to assess whether the mutation is working
        set new-science-knowledge mutate new-science-knowledge
        ;;if length ( remove true ( map [ [a b] -> a = b ] new-science-knowledge1 new-science-knowledge )  ) > 0 [print "mutou"]  ;;*** used to assess whether mutation is working

        ;; bits1 is the tech-knowledge of the receiver
        set bits1 tech-knowledge
        ;; bits2 is the tech-knowledge of the emitter
        set bits2 [tech-knowledge] of partner
        set new-tech-knowledge crossover bits1 bits2
        update-link-appearance new-tech-knowledge tech-knowledge yellow

        ;;**** i can create a string with both knowledge for the update link, and it will sum the differences in both knowledges

      ][;; if both the entity (receiver) and the partner (emitter) possess only scientific knowledge

        ifelse science? and [science?] of partner [
          ;; bits1 is the science-knowledge of the receiver
          let bits1 science-knowledge
          ;; bits2 is the science-knowledge of the emitter
          let bits2 [science-knowledge] of partner
          set new-science-knowledge crossover bits1 bits2

          ;; after learning has been done, also performs a mutation in science knowledge, following traditional genetic algorithms
          ;; let new-science-knowledge1 new-science-knowledge *** used to assess whether the mutation is working
          set new-science-knowledge mutate new-science-knowledge
          update-link-appearance new-science-knowledge science-knowledge green
          ;; if length ( remove true ( map [ [a b] -> a = b ] new-science-knowledge1 new-science-knowledge )  ) > 0 [print "mutou"] *** used to assess whether the mutation is working

        ][;; if both the entity (receiver) and the partner (emitter) possess only technological knowledge
          ;; the code ignores those who don't have any knowledge, but these have been ignored already by the choose-partner procedure

          if technology? and [technology?] of partner [
            ;; bits1 is the tech-knowledge of the receiver
            let bits1 tech-knowledge
            ;; bits2 is the tech-knowledge of the emitter
            let bits2 [tech-knowledge] of partner
            set new-tech-knowledge crossover bits1 bits2
            update-link-appearance new-tech-knowledge tech-knowledge blue
          ]
        ]
      ]

      ;; inserts a memory of this interaction in the receiver's memory
      table:put interaction-memory [who] of partner 0.1
      ;; inserts a memory of this interaction in the emitter's (partner) memory
      table:put [interaction-memory] of partner who 0.1

    ][;; the crossover failed the test of the willingness-to-share-actual or the search for a partner
      ;; in either case the integration, if occurred, failed
      set integration? false
    ]
  ][;; the crossover failed the test of the motivation-to-learn-actual or there are not enough resources
    ;; in either case the integration, if occurred, failed
    set integration? false
  ]

end

;; The integrator facilitates interaction
;; The integrator finds an entity asks it to find a partner.
;; It then boosts the willingness to share an motivation to learn of both of them, facilitating the transaction

to integrate

  let partner1 one-of other entities with [science? or technology?]
  if partner1 != nobody and not crossover? [
    ask partner1 [
      set integration? true
      interact
    ]

    ;; If the integration was sucessful, set integrated? in the integrator
    if [integration?] of partner1 [
      set integrated? true
    ]
  ]

end

;; Crossover procedure from simple genetic algorithm model
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
;; reports one of two strings of bits resulting from single point crossover

to-report crossover [bits1 bits2]

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
;; MUTATION_RATE slider.
;; The cost to mutate is not charged here because mutation may be a by product of learning through crossover
;; or the result of efforts in research. The costs of the first are included in the crossover costs
;; the costs of the second are charged when the mutate procedure is called in the go function

to-report mutate [bits]

   report map [ [b] -> ifelse-value (random-float 100.0 < mutation_rate) [
       1 - b
     ]
     [
       b
     ]
   ] bits

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; niche's procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to mutate-market
  ask niches [
    set niche-demand n-values (Knowledge / 2) [random 2]
    show niche-demand
  ]
end

;; mutation
;; makes the niche call the mutation procedure

;; niche swap
;; not necessary anymore since the simulation only covers the mainstream at this iteration

;; niche learning from introduced products (crossover with consumers)
;; makes the niche call a crossover to one of the consumers. Not necessarily the fittest


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

  if color_update_rule = "fitness" [
    ;; implements the color updating by absolute fitness
    ifelse (fitness / (knowledge / 2 )) > 0.67 [
      set color green
    ]
    [
      ifelse (fitness / (knowledge / 2 )) > 0.33 [
        set color yellow
      ]
      [
        set color red
      ]
    ]
  ]
    ;; implements the color updating by survivability, the amount of iterations the entity would
    ;; be able to survive without receiving any resources
    ;; of course, it can live longer if it keeps gathering resources from the environment
  if color_update_rule = "survivability"[
    ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 10) [
      set color green
    ]
  [ ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 5) [ set color yellow ]
    [set color red]
  ]
  ]

  if color_update_rule = "market survivability" [
    ifelse consumer? [
      ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 10) [
        set color green
      ]
      [
        ifelse (resources > ((minimum_resources_to_live + resources * expense_to_live_growth)) * 5) [
          set color yellow
        ]
        [
          set color red
        ]
      ]
    ]
    [
      set color gray
    ]
  ]

end

;; sets the size of the entity proportional to its resources, related to the amount of periods it could live without receiving resources
to set-size-entity

  set size resources / (minimum_resources_to_live + (resources * expense_to_live_growth))
  if size < 0.5 [
    set size 0.5
  ]

end

to update-link-appearance [bits1 bits2 color-link]
  ;; Evaluates whether the crossover and the mutation actually changed bits
  ;; if it did, it changes the color of the link to blue and its thickness to be proportional to the bits changed. If not, it
  ;; colors the link red

  ;let counter-change 0
  ;foreach ( map [ [a b] -> a = b ] new-tech-knowledge tech-knowledge ) [[a] -> if not a [ set counter-change counter-change + 1]]

  let counter-change length remove true ( map [ [ a b ] -> a = b ]  bits1 bits2 )
  ifelse counter-change > 0 [ ask my-links [set color color-link set thickness counter-change / 100]] [ask my-links [set color red]]

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
     "their role in the ecosystem:"
     "  - Generators - stars / hollow stars"
     "  - Consumers - squares / hollow squares"
     "  - Integrators - pentagons"
     "  - Diffusers - triangles / hollow triangles"
     "  - Hybrids - circles"
     "The hollow shapes are used when a super"
     "entity is created, to differentiate it from"
     "the regular randomly create ones."
    ]
    [
     "Their color denotes several information:"
     " - Blue    - randomly assigned entities"
     " - Orange  - manually assigned entities"
     " - Cyan    - startups"
     " - Magenta - super entities"
     " - Red     - Equal or less than 33% fitness"
     "           - Less than 5 iterations in resources"
     " - Yellow  - More than 33% fitness"
     "           - More than 5 iterations in resources"
     " - Green   - More than 67% fitness"
     "           - More than 10 iterations in resources"
     " - Gray    - Entities do not receive resouces from"
     "the market."
    ]
    [
     "The colors during run time depend on the chooser"
     "color_update_rule. You can choose:"
     " - fitness:              colors by fitness"
     " - survivability:        color by amount of resources"
     " - market survivability: colors by amount of "
     "resources and market dependency."
     "The chooser repeat_simulation? uses the last seed"
     "used for the random number generator or not."
     " If you choose not to repeat, the chooser "
     "set_input_seed? will prompt the user for a seed or"
     "allow the model to randomly select the seed used."
     "In any case, the seed used will be displayed in "
     "the my-seed-repeat monitor."
    ]
    [
     "When you press SETUP, if you chose to "
     "input a known seed for random numbers,"
     "you will be prompted for a integer number."
     "A population of entities with parameters "
     "randomly set is created."
     "The amount of entities at each role may"
     "be randomly or manually chosen through sliders"
     "and the random_ent_creation? chooser."
     "The first color the entities display depend"
     "on how they were created."
    ]
    [
     "Their DNA's are randomly created, and their"
     "parameters are randomly set according to the"
     "mean value and standard deviation chosen,"
     "in a normal distribution fashion."
     "Scientific knowledge and technological"
     "knowledge is assigned according to the"
     "entities roles in the ecosystem."
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
    [
      "The motivation to learn slider will determine"
      "how likelly it is for the entity to contact"
      "other entities."
      "It's standard deviation will create a diverse"
      "population regarding this motivation"
      "The willingness to share will determine how"
      "likelly it is for the entity to reply an"
      "interaction request by another entity"
    ]
    [
      "The mutation rate alters the rate at which"
      "entities with scientific knowledge will"
      "mutate after interacting with other entities"
      "with scientific knowledge for crossover"
      "effectively creating new knowledge"
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
14
10
69
43
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
399
547
574
580
number_of_entities
number_of_entities
1
600
200.0
1
1
NIL
HORIZONTAL

SLIDER
16
147
191
180
Knowledge
Knowledge
2
200
100.0
2
1
NIL
HORIZONTAL

SLIDER
16
179
191
212
initial_resources
initial_resources
1
1000
501.0
1
1
NIL
HORIZONTAL

BUTTON
73
10
131
43
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
16
734
359
917
12

BUTTON
15
700
193
733
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
194
700
358
733
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
272
652
358
697
Instruction #
current-instruction-label
17
1
11

SLIDER
16
212
191
245
niche_resources
niche_resources
0
20000
12000.0
1000
1
NIL
HORIZONTAL

SLIDER
16
245
191
278
minimum_resources_to_live
minimum_resources_to_live
1
1000
601.0
100
1
NIL
HORIZONTAL

SLIDER
16
278
191
311
expense_to_live_growth
expense_to_live_growth
0
1
0.1
0.05
1
NIL
HORIZONTAL

PLOT
813
11
1013
161
Fitness of entities histogram (%)
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
Average fitness of generators (%)
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
"Average fitness" 1.0 0 -2674135 true "" "plot ((mean [fitness] of entities with [generator?])/(Knowledge / 2)) * 100 "

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
372
447
548
492
color_update_rule
color_update_rule
"fitness" "survivability" "market survivability"
0

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
136
10
191
43
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
278
10
364
70
stop_trigger
2000.0
1
0
Number

SLIDER
194
100
369
133
motivation_to_learn
motivation_to_learn
0.00
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
194
166
369
199
willingness_to_share
willingness_to_share
0
1
0.45
0.05
1
NIL
HORIZONTAL

SLIDER
194
232
369
265
mutation_rate
mutation_rate
0
0.1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
194
133
369
166
std_dev_motivation
std_dev_motivation
0
0.5
0.2
0.05
1
NIL
HORIZONTAL

SLIDER
194
199
369
232
std_dev_willingness
std_dev_willingness
0
0.5
0.2
0.05
1
NIL
HORIZONTAL

PLOT
813
446
1013
596
Average motivation to learn
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [motivation-to-learn] of entities) / (count entities)"

PLOT
1013
447
1213
597
Average willingness to share
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [willingness-to-share] of entities) / (count entities)"

MONITOR
813
596
1012
641
Maximum motivation to learn
max [motivation-to-learn] of entities
2
1
11

MONITOR
1012
597
1212
642
Maximum willingness to share
max [willingness-to-share] of entities
2
1
11

MONITOR
813
640
1012
685
Minimum motivation to learn
min [motivation-to-learn] of entities
2
1
11

MONITOR
1012
640
1212
685
Minimum willingness to share
min [willingness-to-share] of entities
2
1
11

MONITOR
814
686
1012
731
Std deviation motivation to learn
standard-deviation [motivation-to-learn] of entities
2
1
11

MONITOR
1014
686
1210
731
Std deviation willingness to share
standard-deviation [willingness-to-share] of entities
2
1
11

SLIDER
16
312
190
345
cost_of_crossover
cost_of_crossover
0
1000
0.0
100
1
NIL
HORIZONTAL

SLIDER
16
377
189
410
cost_of_mutation
cost_of_mutation
0
1000
0.0
100
1
NIL
HORIZONTAL

SLIDER
16
344
189
377
cost_of_development
cost_of_development
0
1000
0.0
100
1
NIL
HORIZONTAL

SLIDER
195
352
368
385
development_performance
development_performance
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
195
428
368
461
creation_performance
creation_performance
0
1
1.0
0.05
1
NIL
HORIZONTAL

SLIDER
195
461
368
494
std_dev_creation_performance
std_dev_creation_performance
0
.5
0.2
.05
1
NIL
HORIZONTAL

BUTTON
12
432
187
465
NIL
create-super-competitor
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
195
384
368
417
std_dev_development_performance
std_dev_development_performance
0
0.5
0.2
0.05
1
NIL
HORIZONTAL

SWITCH
13
531
187
564
super_share?
super_share?
0
1
-1000

BUTTON
14
596
187
629
NIL
mutate-market
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
14
629
187
662
non_economical_entities?
non_economical_entities?
0
1
-1000

SLIDER
196
289
368
322
integration_boost
integration_boost
0
1
0.2
0.05
1
NIL
HORIZONTAL

SWITCH
14
88
190
121
set_input_seed?
set_input_seed?
1
1
-1000

SWITCH
14
49
191
82
repeat_simulation?
repeat_simulation?
0
1
-1000

INPUTBOX
193
10
277
70
my-seed-repeat
-1.392489156E9
1
0
Number

PLOT
1274
51
1528
201
Entities that shared knowledge
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plot count entities with [emitted?]"

PLOT
1533
51
1789
201
Entities that attempted to learn
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -5825686 true "" "plot count entities with [crossover?]"

PLOT
1274
204
1529
354
Entities that attempted mutation
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot count entities with [mutation?]"

PLOT
1533
204
1789
354
Entities that integrated partners
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count entities with [integrated?]"

PLOT
1274
357
1530
507
Consumers that attempted crossover
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count entities with [consumer? and crossover?]"

PLOT
1534
357
1790
507
Generators that attempted mutation
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot count entities with [generator? and mutation?]"

PLOT
1274
510
1530
660
Entities that attempted development
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count entities with [development?]"

PLOT
1534
509
1790
659
Entities alive
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count entities"

TEXTBOX
54
127
204
145
World parameters
11
0.0
1

TEXTBOX
218
82
368
100
General Agent Parameters
11
0.0
1

TEXTBOX
230
274
380
292
Integrator's parameter
11
0.0
1

TEXTBOX
215
331
365
349
Generation and development
11
0.0
1

TEXTBOX
20
580
170
598
Instructions and seed origin
11
0.0
1

TEXTBOX
55
416
205
434
Special functions
11
0.0
1

SLIDER
398
645
576
678
number_of_generators
number_of_generators
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
578
645
753
678
number_of_consumers
number_of_consumers
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
398
725
576
758
number_of_integrators
number_of_integrators
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
578
725
753
758
number_of_diffusers
number_of_diffusers
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
403
825
575
858
number_of_cons_gen
number_of_cons_gen
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
554
582
704
600
Pure entities
11
0.0
1

TEXTBOX
546
763
696
781
Hybrid entities
11
0.0
1

SLIDER
577
825
749
858
number_of_gen_dif
number_of_gen_dif
0
100
0.0
1
1
NIL
HORIZONTAL

SWITCH
575
547
755
580
random_ent_creation?
random_ent_creation?
0
1
-1000

MONITOR
529
501
617
546
NIL
count entities
17
1
11

MONITOR
398
599
576
644
Pure generators
count entities with [generator? and not consumer? and not diffuser? and not integrator?]
17
1
11

MONITOR
577
599
753
644
Pure consumers
count entities with [ not generator? and consumer? and not diffuser? and not integrator?]
17
1
11

MONITOR
398
679
576
724
Pure integrators
count entities with [not generator? and not consumer? and not diffuser? and integrator?]
17
1
11

MONITOR
577
679
753
724
Pure diffusers
count entities with [not generator? and not consumer? and diffuser? and not integrator?]
17
1
11

MONITOR
403
780
575
825
Generators-consumers
count entities with [generator? and consumer? and not diffuser? and not integrator?]
17
1
11

MONITOR
577
781
749
826
Generators-diffusers
count entities with [generator? and not consumer? and diffuser? and not integrator?]
17
1
11

BUTTON
12
465
187
498
NIL
create-super-generator
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
12
498
187
531
NIL
create-super-diffuser
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
814
731
1014
881
Average fitness of consumers (%)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ((mean [fitness] of entities with [consumer?]) /(Knowledge / 2)) * 100"

SWITCH
13
563
187
596
startups?
startups?
1
1
-1000

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

star 2
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108
Rectangle -7500403 true true 15 45 15 45
Rectangle -16777216 true false 105 120 195 210

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
