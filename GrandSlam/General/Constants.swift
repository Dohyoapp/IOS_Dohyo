//
//  Constants.swift
//  GrandSlam
//
//  Created by Explocial 6 on 22/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

#if LIVE_VERSION
    let URL_ROOT = "https://api.ladbrokes.com/"
#elseif DEV_VERSION
    let URL_ROOT = "https://api.ladbrokes.com/"
#else
    let URL_ROOT = "https://api.ladbrokes.com/"
#endif

//devAPPKey "XCYnUIgcJKdPcW8u5FsiqMFeL0sFZDiWoeqWrUn2"
let PARSE_APPLICATION_KEY = "ZliITZEO4ZM30ObrmYb6tPuJwnjFaQJnmp27cU80"

//devClientKey "XIV8NiEBmQDm54CskEMMC8BeEdD2QeTlUAz1m1Mf"
let PARSE_CLIENT_KEY = "qC9qxdB5ycoZnZgl8l7HOglM37FQfH2ef7hVYB3E"


let MIXPANEL_TOKEN = "261b3280edfef7caa0f7a8e9a422287a"

var TEAMS_IMAGES_URL_ROOT = "https://s3.amazonaws.com/grandslam-explovia/"

let LADBROKES_API_KEY = "l7xx338f4665095b4e4bb2733e9a7fe4bf3c"



let KEYBOARD_HEIGHT = 216 as CGFloat

let NAVIGATIONBAR_HEIGHT = 55 as CGFloat
let YSTART = NAVIGATIONBAR_HEIGHT+20


let SPECIALBLUE = UIColor(red:54/255.0, green:137/255.0, blue:193/255.0, alpha:1)



let FONT1 = "Avenir-Book"
let FONT2 = "Avenir-Black"
let FONT3 = "Avenir-Medium"
let FONT4 = "Avenir-Heavy"