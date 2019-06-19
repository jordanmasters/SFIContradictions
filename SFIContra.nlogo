;; Random notes

;; Issue 1
;; would like create-ordered-list from inside turtle ask, but not possible so using
;; foreach groupxys procedure instead - possible solution is to avoid foreach, use ask, but make custom hatch function with spacially ordered turtles to be axecutable from inside ask
;; goal was to make turtles have same ID as their group - solved by adding group index to temp groupxys list

;; Issue 2
;;

extensions [ rnd ]

turtles-own [mygroup my-position vote-prob vote-this-round]

breed [groups group]
breed [allcs allc]
breed [allds alld]
breed [rcs rc]

globals [groupxys ordered-groups ordered-groups-set types popular-vote global-vote global-vote-weighted groups-positions groups-positions-weighted consensus consensus-weighted]


to setup
  clear-all
  make-groups
  decentralized-heirarchical-split ;; hardcode this so we done need to see it in the interface
  populate-groups

  ;; put this in a function ....
  set consensus []
  set consensus-weighted []
  set groups-positions-weighted []
  ;set global-vote-weighted []
  let p-len range percieved-consensus-len
  foreach p-len
  [ fake-consent -> set consensus fput (random-float 2 - 1) consensus;show (word x " -> " round x)
    ;sum [my-position] of turtles with [mygroup = group-num]
  ]
  ;show consensus



  reset-ticks
end

to go
  draw-voters
  calc-group-vote
  calc-popular-vote
  die-birth
  tick
end




to draw-voters
  ; for all turtles with who greater than m (the number of groups - bs group count take up first m who values)
  ;ask turtles with [who > rows * columns]
  ;1 / sqrt n


  ; each round reinit all agents vote-this-round to true
  ask turtles with [who >= rows * columns] [
    set vote-this-round True
  ]

  ; then select new voters if applicatble
  if not mandatory-voting? [
    ask turtles [
      if vote-prob < random-float 1 [
        set vote-this-round False
      ]

    ]
  ]
end

to calc-popular-vote
  set popular-vote (sum [my-position] of turtles) / (count turtles - (rows * columns))
end

to calc-group-vote



  set groups-positions []
  let m rows * columns
  let m-list range m
  let con-len length consensus
  let con-len-back length consensus - percieved-consensus-len

;  show "loop!"
;  foreach m-list
;  [ group-num -> show turtles with [mygroup = group-num and vote-this-round = True]
;    ;set groups-positions ([my-position] of turtles with [mygroup = group-num]) ;+ sum sublist con-len con-len-back * (1 - se))     ;show (word x " -> " round x)
;
;    ;sum [my-position] of turtles with [mygroup = group-num]
;  ]


  foreach m-list
  [ group-num -> set groups-positions ([my-position] of turtles with [mygroup = group-num and vote-this-round = True]) ;+ sum sublist con-len con-len-back * (1 - se))     ;show (word x " -> " round x)

    ;sum [my-position] of turtles with [mygroup = group-num]
  ]
;  show "group pos"
;  show groups-positions
;  set groups-positions map [ ? / 100 ] groups-positions

  set groups-positions-weighted []
  foreach groups-positions
  [
  mypos ->
;    show "mypos"
;    show mypos
;    show "self-weight"
;    show self-weight
;    show "mypos * self-weight"
;    show mypos * self-weight
;    show "sum sublist consensus con-len-back con-len"
;    show (sum sublist consensus con-len-back con-len / (con-len - con-len-back))
;;    show "globalpos * 1 - self-weight"
;    show (sum sublist consensus con-len-back con-len / (con-len - con-len-back)) * (1 - self-weight)
    set groups-positions-weighted fput ((mypos * self-weight) + (sum sublist consensus con-len-back con-len / (con-len - con-len-back)) * (1 - self-weight)) groups-positions-weighted
  ]
;  show "group pos weighted"
;  show groups-positions-weighted

  set global-vote sum groups-positions / m
  set consensus fput global-vote consensus

  set global-vote-weighted sum groups-positions-weighted / m
  set consensus-weighted fput global-vote-weighted consensus-weighted

  ;set my-list fput something my-list
end

to calc-global-vote

end

to die-birth
  ask turtles with [who > rows * columns]
  [
    if random-float 1 > prob-live [

      hatch 1 [
        ; dry thid all
        set my-position random-float 2 - 1
        set vote-prob 1 / sqrt group-count
        if my-position > 0 [set color yellow]
        if my-position < 0 [set color sky]
        ;; this is the hackiest single band-aid which should do fine for the amount of batch runs we are trying to do, but perhaps put one more level of manual recursion to force it if its an issue.
        if my-position = 0 [set my-position random-float 2 - 1 ]
      ]
      die
    ]

  ]

end




to make-groups
  set-default-shape turtles "circle"
  create-groups rows * columns
  [
    ;hide-turtle        ;; we don't want to see the spawners
  ]
  arrange-groups
  ;set first-parens nobody
end

to arrange-groups
  ;; arrange the groups around the world in a grid
  let i 0
  while [i < rows * columns]
  [
    ask turtle i
    [
      set color gray
      let x-int world-width / columns
      let y-int world-height / rows
      setxy (-1 * max-pxcor + x-int / 2 + (i mod columns) * x-int)
            (max-pycor + min-pycor / rows - int (i / columns) * y-int)
    ]
    set i i + 1
  ]
end

;; hide this later
to decentralized-heirarchical-split
  ask turtles with [who < rows * columns] [

    ;;if random-float 1 > percent-acephalous
    ;;hide-turtle


  ]
end

to populate-groups
  ; order the list of groups for easy processing
  ; remove from globals - keep this local
  set ordered-groups sort-on [who] turtles

  ; convert the ordered list to an agentset
  set ordered-groups-set turtles with [member? self ordered-groups]

  ;set ordered-groups-set sort-on [whoc ordered-groups-set
  ; create a list of all the xy cors for each group location
  ; there is too much redundency in lists here
  set groupxys [ (list who xcor ycor) ] of ordered-groups-set with [who < rows * columns]
  ;let mygr 0

  ;let group-num 0
  foreach groupxys [
    [ xy_coords ] ->
    populate-group group-radius group-count item 1 xy_coords item 2 xy_coords item 0 xy_coords
    ;mygr
    ;set group-num group-num + 1
  ]
end


to populate-group [radius n x_cors y_cors mygr]
  ;layout-circle turtles 10
  ;; turtles should be evenly spaced around the circle

  create-ordered-turtles n [

    set size 0.3  ;; easier to see
    set mygroup mygr ;; brand turtle with group label
    setxy x_cors y_cors ;; position at group location
    fd radius
    rt 90

    ; set the position for each turtle in a group to unifor between [-1,1] this could be done globally, but for speed of coding...!
    set my-position random-float 2 - 1
    set vote-prob 1 / sqrt group-count

    if my-position > 0 [set color yellow]
    if my-position < 0 [set color sky]
    ;; this is the hackiest single band-aid which should do fine for the amount of batch runs we are trying to do, but perhaps put one more level of manual recursion to force it if its an issue.
    if my-position = 0 [set my-position random-float 2 - 1 ]



    ;; This id Hooper prodecuer
    ;; assign a breed based on p, q, r
    ;;let mytype assign-type
    ;if mytype = "allc" [set breed allcs set color green]
    ;if mytype = "alld" [set breed allds set color red]
    ;if mytype = "rc" [set breed rcs set color yellow]



  ]
end




;; its global but should be local - i hate netlogo, neither way to do this is nice, they already have made qpr global through interface
;to-report  assign-type
;  ;; this is cosmetic-ish, how to pass globals defined by slider into this list of lists
;  ;; without getting "expected a literal value" error.. i made it literal... didn't i
;  ;; The below seems correct, but doesn't work
;  ;; http://netlogo-users.18673.x6.nabble.com/define-variable-in-list-td5005256.html
;
;  ;TRYING TO DEBUG...
;  ;;let a p
;  ;;let b q
;  ;;let c r
;
;  ;;let prob-allc (list 0 a )
;  ;;let prob-alld (list 1 b )
;  ;;let prob-rc (list 2 c )
;  ;;type prob-allc
;  ;;type prob-alld
;  ;;type prob-rc
;
;  ;let types [ [ "allc" p ] [ "alld" 0.3 ] [ "rc" 0.4 ] ]
;  ;set types [prob-allc prob-alld prob-rc]
;
;
;  set types [ ["allc" 0.3 ] [ "alld" 0.3 ] [ "rc" 0.4 ] ]
;
;  report first rnd:weighted-one-of-list types [ [px] -> last px ]
;  ;report "allc"
;
;end
@#$#@#$#@
GRAPHICS-WINDOW
333
10
989
667
-1
-1
19.64
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

SLIDER
13
325
114
358
rows
rows
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
118
325
236
358
columns
columns
1
10
4.0
1
1
NIL
HORIZONTAL

BUTTON
18
17
84
50
NIL
setup
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
161
18
224
51
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

BUTTON
227
18
308
51
go once
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

BUTTON
1934
800
2072
833
NIL
populate-groups
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
1934
668
2086
701
NIL
clear-all\nreset-ticks
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
1934
712
2050
745
NIL
make-groups
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
2129
522
2307
555
percent-acephalous
percent-acephalous
0
1
0.0
0.01
1
NIL
HORIZONTAL

BUTTON
1932
759
2159
792
NIL
decentralized-heirarchical-split
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
13
368
134
401
group-count
group-count
1
30
12.0
1
1
NIL
HORIZONTAL

SLIDER
140
368
261
401
group-radius
group-radius
0.5
3
1.5
0.5
1
NIL
HORIZONTAL

TEXTBOX
1935
614
2146
644
Manual Setup\n
24
0.0
1

SLIDER
2220
702
2392
735
p
p
0
1 - q - r
0.82
0.01
1
NIL
HORIZONTAL

SLIDER
2219
742
2391
775
q
q
0
1 - p - r
0.09
0.01
1
NIL
HORIZONTAL

SLIDER
2219
782
2391
815
r
r
0
1 - p - q
0.09
0.01
1
NIL
HORIZONTAL

TEXTBOX
2219
656
2544
685
p q r - Joint Force maxed to 1
22
0.0
1

SLIDER
17
206
229
239
percieved-consensus-len
percieved-consensus-len
1
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
16
121
188
154
self-weight
self-weight
0.00
1
0.24
0.01
1
NIL
HORIZONTAL

SLIDER
17
165
189
198
prob-live
prob-live
0
1
0.95
0.01
1
NIL
HORIZONTAL

PLOT
1015
34
1215
184
Popular Vote
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot popular-vote"

MONITOR
1227
34
1386
115
Popular Vote
popular-vote
2
1
20

PLOT
1634
205
1834
355
Global Vote_1
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot global-vote"

PLOT
1020
403
1220
553
Global vs Popular Vote Diff
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot abs global-vote-weighted - popular-vote"

PLOT
1018
212
1218
362
Global Vote_1
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot global-vote-weighted"

MONITOR
1228
213
1484
294
Global Position
global-vote-weighted
2
1
20

MONITOR
1634
366
1719
411
NIL
global-vote
17
1
11

MONITOR
1227
405
1508
486
Global vs Populal Vote Diff
abs global-vote-weighted - popular-vote
2
1
20

TEXTBOX
21
81
224
111
Agent Settings
24
0.0
1

TEXTBOX
15
280
260
311
Group Settings
24
0.0
1

SWITCH
15
453
190
486
mandatory-voting?
mandatory-voting?
0
1
-1000

MONITOR
1231
596
1355
641
Voters this Round
count turtles with [vote-this-round = true]
17
1
11

MONITOR
1121
595
1213
640
Total Turtles
count turtles - (rows * columns)
17
1
11

TEXTBOX
17
495
167
537
If mandatory voting off - agent vote prob is 1/sqrt(group-count)\n
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>abs global-vote-weighted - popular-vote</metric>
    <enumeratedValueSet variable="self-weight">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percieved-consensus-len">
      <value value="1"/>
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="amount-of-information" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>abs global-vote-weighted - popular-vote</metric>
    <enumeratedValueSet variable="mandatory-voting?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rows">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="columns" first="1" step="5" last="20"/>
    <steppedValueSet variable="group-count" first="1" step="5" last="20"/>
    <enumeratedValueSet variable="self-weight">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-live">
      <value value="0.95"/>
    </enumeratedValueSet>
    <steppedValueSet variable="percieved-consensus-len" first="1" step="5" last="20"/>
  </experiment>
</experiments>
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
