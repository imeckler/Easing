{- Daniël Heres 2014 -}

module Easing where

{-| Library for working with easing.

# Options
@docs EaseOptions, EasingState

# Easing
@docs ease

# Easing functions
@docs linear, 
      easeInQuad, easeOutQuad, easeInOutQuad,
      easeInCubic, easeOutCubic, easeInOutCubic,
      easeInQuart, easeOutQuart, easeInOutQuart,
      easeInSine, easeOutSine, easeInOutSine,
      easeInExpo, easeOutExpo, easeInOutExpo   

-}

import Time (fps, timestamp, Time)

type Easing = EasingOptions -> Time -> Time -> Float

{-| Options for easing.
* <b>from</b> is value at the start
* <b>to</b> is the value at the end
* <b>duration</b> is the time the easing takes
* <b>easing</b> is the easing function
-}
type EaseOptions = 
    { from     : Float
    , to       : Float
    , duration : Time
    , easing   : Easing
    }

type EasingOptions = 
    { from     : Float
    , to       : Float
    , duration : Time
    }

type PlayState =
    { playing : Bool
    }

{-| Represents the state of the easing
* <b>value</b> is the value at the current time
* <b>playing</b> whether the easing function is in progress or not
-}
type EasingState =
    { value   : Float
    , playing : Bool
    }

linear : Easing
linear o c t = c * t / o.duration + o.from

easeInQuad : Easing
easeInQuad o c t = c * (t / o.duration) ^ 2 + o.from

easeOutQuad : Easing
easeOutQuad o c t = 
    let 
        t' = t / o.duration 
    in 
        -c * t'*(t'-2) + o.from
        
easeInOutQuad : Easing 
easeInOutQuad o c t = 
    let 
        t' = t / (o.duration / 2)
        t2 = t' - 1
    in
        if isFirstHalf o t then c / 2 * t' * t' + o.from else (-c / 2) * (t2 * (t2 - 2) - 1) + o.from

easeInCubic : Easing
easeInCubic o c t =
    let 
        t' = t / o.duration 
    in  
        c * t' * t' * t' + o.from
        
easeOutCubic : Easing
easeOutCubic o c t =
    let 
        t' = t / o.duration  - 1
    in  
        c * (t' * t' * t' + 1) + o.from
        
easeInOutCubic : Easing
easeInOutCubic o c t =
    let
        t' = t / (o.duration / 2)
        t2 = t' - 2
    in
        if isFirstHalf o t then
            c / 2 * t' * t' * t' + o.from
        else
            c / 2 * (t2 * t2 * t2 + 2) + o.from
        
easeInQuart : Easing
easeInQuart o c t = 
    let 
        t' = t / o.duration
    in
        c * t' * t' * t' * t' + o.from
        
easeOutQuart : Easing
easeOutQuart o c t = 
    let
        t'= t / o.duration - 1
    in
        -c * (t' * t' * t' * t' - 1) + o.from

easeInOutQuart : Easing
easeInOutQuart o c t = 
    let
        t' = t / (o.duration / 2)
        t2 = t' - 2
    in
        if isFirstHalf o t then
            c / 2 * t' * t' * t' * t' + o.from
        else
            -c / 2 * (t2 * t2 * t2 * t2 - 2) + o.from
        
easeInSine : Easing
easeInSine o c t = -c * cos(t / o.duration * (pi/2)) + c + o.from

easeOutSine : Easing
easeOutSine o c t = c * sin(t / o.duration * (pi/2)) + o.from

easeInOutSine : Easing
easeInOutSine o c t = -c / 2 * (cos (pi * t / o.duration) - 1) + o.from

easeInExpo : Easing
easeInExpo o c t = c * 2 ^ (10 * (t / o.duration - 1)) + o.from

easeOutExpo : Easing
easeOutExpo o c t = c * ( -( 2 ^ (-10 * t / o.duration )) + 1 ) + o.from

easeInOutExpo : Easing
easeInOutExpo o c t =
    let
        t' =  t / (o.duration / 2)
        t2 =  t' - 1
    in
        if isFirstHalf o t then
            c / 2 * (2 ^ (10 * (t' - 1))) + o.from
        else
            c / 2 * (-(2 ^ (-10 * t2)) + 2) + o.from
            
                       
   
isPlaying : EasingOptions -> Float -> Bool
isPlaying o t = t < o.duration

isFirstHalf : EasingOptions -> Float -> Bool
isFirstHalf o t = t < o.duration / 2

{-| Apply an ease function
    `ease { from = 0.0, to = 400.0, duration = 3000, easing = linear}`
Returns a signal with an `EasingState`.
-} 
ease : EaseOptions -> Signal EasingState
ease o = 
    let 
        b = lift fst <| timestamp (constant ())
        s x = lift2 (,) x b
        e ((t, _),b) _ = 
            let n = o.easing {o - easing} (o.to - o.from) (t-b)
                p = isPlaying {o - easing} (t-b)
            in {playing = p, value = if p then n else o.to}
    in  
    
        foldp e {value = o.from, playing = True} (s (timestamp (fps 60)))

main = lift (asText . .value) <| ease { from = 0.0, to = 400.0, duration = 3000, easing = easeInOutExpo}
