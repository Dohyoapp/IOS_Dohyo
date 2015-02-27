
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var League  = Parse.Object.extend("League");
var Event   = Parse.Object.extend("Event");


function clearLog(){

  for(var i = 0; i < 100; i++)
    console.log("");
}



Parse.Cloud.afterSave("Event", function(request) {



});



var matchCount;
function getPointUser(user, customLeagueId, response){

  var relation  = user.relation("betSlips");
  var query     = relation.query();
  query.equalTo("customLeagueId", customLeagueId);
  query.find({
      success:function(results) {
            

        var userPoints = 0;
        var theBetSlip = results[0];
            
        if(theBetSlip != null){

              var bets = theBetSlip.get("bets");
              var matchsIdArray = new Array();
              for(var j = 0; j < bets.length; j++){

                   var betMatch = bets[j];
                   matchsIdArray.push(betMatch.matchId) 
             }
             
             
              var query = new Parse.Query("Event");
              query.containedIn("objectId", matchsIdArray)
              query.find({
                  success: function(results) {
                      
                       usersCount = usersCount-1;

                       for(var i = 0; i < results.length; i++){
                           var matchData = results[i];
                      
                           var finalMatchScore = matchData.get("finalScore");
                           if(finalMatchScore != null){

                               var finalScores     = finalMatchScore.split(' - ');
                               if(finalScores.length > 1){

                                  var homeFinalScore  = finalScores[0];
                                  var awayFinalScore  = finalScores[1];

                                  for(var k = 0; k < bets.length; k++){

                                      var betMatch = bets[k];
                                      var predictedMatchScore = betMatch.selection.selectionName
                      
                                      var titleMatch = matchData.get("title");
                                      var arrayTeamsName = titleMatch.split(' V ');
                                      if(arrayTeamsName.length > 1){

                                         var nameHomeTeamEvent = shortTeamName(arrayTeamsName[0]);
                                         var nameAwayTeamEvent = shortTeamName(arrayTeamsName[1]);

                                         var winTeamName = shortTeamName(predictedMatchScore.substring(0, predictedMatchScore.length-6));
                                         var predictedScoreString = predictedMatchScore.substring(predictedMatchScore.length-5);
                                 
                                         var predictedScoreArray  = predictedScoreString.split(' - ');

                                         var homePredictedScore;
                                         var awayPredictedScore;
                                        if(winTeamName == nameHomeTeamEvent){
                                            homePredictedScore = predictedScoreArray[0]
                                            awayPredictedScore = predictedScoreArray[1]
                                        }
                                        else{
                                            homePredictedScore = predictedScoreArray[1]
                                           awayPredictedScore = predictedScoreArray[0]
                                        }

                                       if(homePredictedScore == homeFinalScore && awayPredictedScore == awayFinalScore)
                                           userPoints = userPoints+10;
                                       else{

                                          if(parseInt(homePredictedScore) > parseInt(awayPredictedScore) && parseInt(homeFinalScore) > parseInt(awayFinalScore))
                                             userPoints = userPoints+4;
                                         
                                          if(parseInt(awayPredictedScore) > parseInt(homePredictedScore) && parseInt(awayFinalScore) > parseInt(homeFinalScore))
                                              userPoints = userPoints+4;

                                          if(parseInt(awayPredictedScore) == parseInt(homePredictedScore) && parseInt(awayFinalScore)== parseInt(homeFinalScore))
                                              userPoints = userPoints+4;
                                        }

                                      }
                                  }//end second For

                               }//finalScores.length > 1

                            }//finalMatchScore != nil if

                       }//end for
                       returnUsersPointArray.push({"user": user, "userPoints": ""+userPoints})
                       if(usersCount == 0)
                          response.success(returnUsersPointArray)
                         
                  }
              });

          }
          else{

              usersCount = usersCount-1;
              returnUsersPointArray.push({"user": user, "userPoints": "0"})
              if(usersCount == 0)
                  response.success(returnUsersPointArray)
          }

      }//betSlip query succes
   });
}

var usersCount;
var returnUsersPointArray 
Parse.Cloud.define("getUsersByUsersId", function(request, response) {

  returnUsersPointArray  = new Array();
  var customLeagueId     = request.params.customLeagueId;

  
  var query = new Parse.Query("CustomLeague");
  query.equalTo("objectId", customLeagueId);
  query.find({
      success: function(results) {

        var customLeague = results[0];
        
        var usersIdArray = new Array();
        if(customLeague.get("mainUser") != null){
            usersIdArray.push(customLeague.get("mainUser"));
        }
        
        if(customLeague.get("joinUsers") != null){
            var users = customLeague.get("joinUsers");
            for(var t = 0; t < users.length; t++){
              usersIdArray.push(users[t]);
            }
        }
        

        var query  = new Parse.Query("User");
        query.containedIn("objectId", usersIdArray);
        query.find({
               success: function(results) {

                  usersCount = 0;
                  if(results.length > 0)  usersCount = results.length
                  
                  for(var i = 0; i < results.length; i++){

                     var user = results[i];
                     getPointUser(user, customLeagueId, response);
                  }
               }
         });

      } 
  });
  
});




Parse.Cloud.define("NewJoinLeagueNumber", function(request, response) {

  var user = Parse.User.current()
  //var date  = request.params.JoinViewDate;
  var date  = user.get("LastJoinViewDate")
  if(date == null){
    response.success(new Array());
  }
  

  var query = new Parse.Query("CustomLeague");
  query.notEqualTo("mainUser", user.id);
  query.greaterThanOrEqualTo("createdAt", date);
  query.limit(1000)
  query.find({
      success: function(results) {
      
          var returnArray   = new Array();
          var countPublic   = 0;
          var countPrivate  = 0;

          for(var i = 0; i < results.length; i++){

            var customLeague = results[i];
            
            if(customLeague.get("public")){

              var joinUsers = customLeague.get("joinUsers")
              var isAllreadyJoin = false
              if(joinUsers != null){

                 for(var k = 0; k < joinUsers.length; k++){

                    var joinUserId = joinUsers[k]
                    if(joinUserId == user.id)
                       isAllreadyJoin = true
                 }
              }

              if(!isAllreadyJoin)
                 countPublic ++;
            }
              
            
            if(!customLeague.get("public")){//private
            
              var joinUsers = customLeague.get("joinUsers")
              var isAllreadyJoin = false
              if(joinUsers != null){

                  for(var k = 0; k < joinUsers.length; k++){

                    var joinUserId = joinUsers[k]
                    if(joinUserId == user.id)
                       isAllreadyJoin = true
                 }
              }

              if(!isAllreadyJoin){

                var friends = user.get("friends")
                for (var j = 0; j < friends.length; j++){

                  var friendId = friends[j]
                  if(friendId == customLeague.get("mainUser")){
                    countPrivate ++;
                  }
                }
              }
              
            }
          }


          returnArray.push(countPublic);
          returnArray.push(countPrivate);

          response.success(returnArray);
      }
  });

});


Parse.Cloud.job("getLeaguesFromHttp", function(request, status) {
  
    //var leagueUrl = "https://api.ladbrokes.com/v2/sportsbook-api/classes/110000006/types/110000557/subtypes/84";
    var leagueUrl = "https://api.ladbrokes.com/v2/sportsbook-api/classes/"+"110000006";
    loadLeagueV2(leagueUrl, "Premier League");
    //loadLeagueV2(leagueUrl, "Championship");
    //clearLog();ap
});



function addNewEventLeague(eventleagueJSON2, league, relation){

      var myEvent = new Event();
      myEvent.set("title", eventleagueJSON2.title);
      myEvent.set("link", eventleagueJSON2.href);
      myEvent.save(null, {
              success: function(object) {
                getMarketEvent(object);
                relation.add(object);
                league.save(); 
              }
      });
}

function addNewEventLeagueV2(eventleagueJSON, league, relation){

      var myEvent = new Event();
      myEvent.set("title", eventleagueJSON.eventName);
      myEvent.set("eventKey", eventleagueJSON.eventKey);
      myEvent.set("league", league);
      myEvent.set("eventDateTime", eventleagueJSON.eventDateTime);
      myEvent.save(null, {
              success: function(object) {
                getMarketEventV2(object);
                relation.add(object);
                league.save(); 
              }
      });
}


function addEventsToLeague(eventsLeaguesJSON, league){

  var relation = league.relation("events");
  var query = relation.query();
  query.find({
        success:function(list) {

          for (var i = 5; i < eventsLeaguesJSON.length; i++) {

             var eventExist = false;
             var eventleagueJSON2 = eventsLeaguesJSON[i];
             var eventLeagueSaved;

             for(var j = 0; j < list.length; j++){

                eventLeagueSaved = list[j];
                if(eventLeagueSaved.get("title") == eventleagueJSON2.title){
                    eventExist = true;
                    break;
                }
                   
             }


             if(eventExist){  // update Events
                  eventLeagueSaved.set("title", eventleagueJSON2.title);
                  eventLeagueSaved.set("link", eventleagueJSON2.href);
                  eventLeagueSaved.save();
                  getMarketEvent(eventLeagueSaved);
              } 
              else{
                 addNewEventLeague(eventleagueJSON2, league, relation);
              }
              
          }

           //delete old events
           for(var k = 0; k < list.length; k++){

             var savedEventExist = false;
             var eventLeagueSaved2 = list[k];

             for (var l = 5; l < eventsLeaguesJSON.length; l++) {
                var eventleagueJSON3 = eventsLeaguesJSON[l];
                if(eventLeagueSaved2.get("title") == eventleagueJSON3.title)
                   savedEventExist = true;
             }

             if(!savedEventExist)
                eventLeagueSaved2.destroy();
              
           }
        }
  });
   
}


function addEventsToLeagueV2(eventsLeaguesJSON, league){

  var relation = league.relation("events");
  var query = relation.query();
  relation.query().limit(1000);
  query.find({
        success:function(list) {

          for (var i = 0; i < eventsLeaguesJSON.length; i++) {

             var eventExist = false;
             var eventleagueJSON = eventsLeaguesJSON[i];
             var eventLeagueSaved;

             for(var j = 0; j < list.length; j++){

                eventLeagueSaved = list[j];
                if(eventLeagueSaved.get("title") == eventleagueJSON.eventName){
                    eventExist = true;
                    break;
                }
                   
             }


             if(eventExist){  // update Events
                  eventLeagueSaved.set("title", eventleagueJSON.eventName);
                  eventLeagueSaved.set("eventKey", eventleagueJSON.eventKey);
                  eventLeagueSaved.set("league", league);
                  eventLeagueSaved.set("eventDateTime", eventleagueJSON.eventDateTime);
                  eventLeagueSaved.save();
                  getMarketEventV2(eventLeagueSaved);
              } 
              else{
                 addNewEventLeagueV2(eventleagueJSON, league, relation);
              }
              
          }

           //delete old events
           /*
           for(var k = 0; k < list.length; k++){

             var savedEventExist = false;
             var eventLeagueSaved2 = list[k];

             for (var l = 0; l < eventsLeaguesJSON.length; l++) {
                var eventleagueJSON2 = eventsLeaguesJSON[l];
                if(eventLeagueSaved2.get("title") == eventleagueJSON2.eventName)
                   savedEventExist = true;
             }

             if(!savedEventExist)
                eventLeagueSaved2.destroy();
              
           }*/
        }
  });
   
}



function addLeagueV1(eventsLeaguesJSON){

  var eventleagueJSON = eventsLeaguesJSON[0];
  var query = new Parse.Query("League");
  query.equalTo("title", eventleagueJSON.title)
  query.find({
      success: function(results) {
          // Successfully retrieved the object.
          var league;
          if(!results || results.length == 0){
            
            league = new League();
            league.set("title", eventleagueJSON.title); 
            league.save(null, {
              success: function(object) {
                  addEventsToLeague(eventsLeaguesJSON, object);
              }
            });

          }else{
             league = results[0];
             addEventsToLeague(eventsLeaguesJSON, league);
           }
      }
  });
}


function loadLeagueV1(leagueUrl, leagueName){

   Parse.Cloud.httpRequest({
   url: leagueUrl,
   headers: {
      "Accept" : "application/json",
      "User-Agent": "CERN-LineMode/2.15 libwww/2.17b3"
      },
   params: {
       "locale" : "en-GB",
       "api-key" : "l7xx338f4665095b4e4bb2733e9a7fe4bf3c",
    },
    
     success: function(httpResponse) {

        var obj = JSON.parse(httpResponse.text);
        addLeagueV1(obj.subtype.links.link);
     },
     error: function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.text);
     }
   });
}






function addLeagueV2(subType, typeKey, classKey){

  var leagueName = subType.subTypeName;
  var query = new Parse.Query("League");
  query.equalTo("title", leagueName)
  query.find({
      success: function(results) {
          // Successfully retrieved the object.
          var league;
          if(!results || results.length == 0)
            league = new League();
          else
             league = results[0];
          
            league.set("title", leagueName); 
            league.set("classKey", classKey); 
            league.set("typeKey", typeKey); 
            league.set("subTypeKey", subType.subTypeKey);
            league.save(null, {
              success: function(object) {
                  addEventsToLeagueV2(subType.events.event, object);
              }
            });
      }
  });
}


function loadLeagueV2(leagueUrl, leagueName){

   Parse.Cloud.httpRequest({
   url: leagueUrl,
   headers: {
      "Accept" : "application/json",
      "User-Agent": "CERN-LineMode/2.15 libwww/2.17b3"
      },
   params: {
       "locale" : "en-GB",
       "api-key" : "l7xx338f4665095b4e4bb2733e9a7fe4bf3c",
       "expand" : "event",
       "filter" : "event.is-open-event"
    },
    
     success: function(httpResponse) {

        var object    = JSON.parse(httpResponse.text);
        var types     = object.classes.class.types.type;
        var classKey  = object.classes.class.classKey;

        var subTypes;
        var typeKey;
        for(var i = 0; i < types.length; i++){
          var type = types[i];
          if(type.typeName == "English"){
            subTypes = type.subtypes.subtype;
            typeKey = type.typeKey;
          }
        }
        
        for(var j = 0; j < subTypes.length; j++){
          var subType = subTypes[j];
          if(subType.subTypeName == leagueName)
            addLeagueV2(subType, typeKey, classKey);
        }
     },
     error: function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.text);
     }
   });
}




////////////////////////////*******************************////////////////////////////


function getMarketEvent(eventleague){

     Parse.Cloud.httpRequest({
     url: eventleague.get("link"),
     headers: {
        "Accept" : "application/json",
        "User-Agent": "CERN-LineMode/2.15 libwww/2.17b3"
      },
    
     success: function(httpResponse) {
      
        var obj = JSON.parse(httpResponse.text);
        var marketsEventJson = obj.event.links.link;
        
        if(marketsEventJson && marketsEventJson.length > 0){
        
          for(var i = 0; i < marketsEventJson.length; i++){
          
           var marketJson = marketsEventJson[i];
           if(marketJson && (marketJson.title == "Correct score")){
              //marketJson.set("marketUrl" , marketJson.href);
              //marketJson.save();
              loadEventOdds(eventleague, marketJson.href);
           }
              
         }
        }
     },
     error: function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.text);
     }
   });
}



function loadEventOdds(marketEvent, link){

   Parse.Cloud.httpRequest({
     url: link,
     headers: {
        "Accept" : "application/json",
        "User-Agent": "CERN-LineMode/2.15 libwww/2.17b3"
      },
    
     success: function(httpResponse) {

          var obj = JSON.parse(httpResponse.text);
          marketEvent.set("oddsUrl" , obj.market.links.link);
          marketEvent.save();
      },
     error: function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.text);
     }
   });
}



function getMarketEventV2(eventleague){

    var league = eventleague.get("league");
    var link = "https://api.ladbrokes.com/v2/sportsbook-api/classes/"+league.get("classKey")+"/types/"+league.get("typeKey")+"/subtypes/"+league.get("subTypeKey")+"/events/"+eventleague.get("eventKey");
    
     Parse.Cloud.httpRequest({
     url: link,
     headers: {
        "Accept" : "application/json",
        "User-Agent": "CERN-LineMode/2.15 libwww/2.17b3"
      },
      params: {
       "locale" : "en-GB",
       "api-key" : "l7xx338f4665095b4e4bb2733e9a7fe4bf3c",
       "expand" : "selection",
     },
    
     success: function(httpResponse) {
       
        var object           = JSON.parse(httpResponse.text);
        var marketsEventJson = object.event.markets.market;
        
          for(var i = 0; i < marketsEventJson.length; i++){
          
              var marketJson = marketsEventJson[i];
             if(marketJson && (marketJson.marketName == "Correct score")){
              
               eventleague.set("CorrectScore", marketJson.selections.selection);
             }
             if(marketJson && (marketJson.marketName == "Match betting")){
              
               eventleague.set("MatchBetting", marketJson.selections.selection);
             }

             eventleague.save(); 
          }
     },
     error: function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.text);
     }
   });
}




var allEvents;
function getAllEvents(status, response){
    
    var query = new Parse.Query("Event");
    query.limit(1000);
    query.find({
        success: function(results) {
           allEvents = results
           
           getAllMatchResult(0, response, status)
        }
    });
}

Parse.Cloud.job("getMatchesScores", function(request, status) {
    
    var scoresUrl = "http://www.football-data.co.uk/mmz4281/1415/E0.csv";
    
    Parse.Cloud.httpRequest({ url: scoresUrl }).then(function(response) {
        
        getAllEvents(status, response)
    });
  
});

var matchResults;
function getAllMatchResult(loopCount, response, status){

    ///set your record limit
    var limit = 1000;
    if(loopCount == 0){
      matchResults = new Array();
    }

    ///create your eggstra-special query
     new Parse.Query("MatchResult")
            .limit(limit)
            .skip(limit * loopCount) //<-important
            .find({
             success: function (results) {
                 if(results.length > 0){

                     //we do stuff in here like "add items to a collection of cool things"
                     for(var j=0; j < results.length; j++){
                         matchResults.push(results[j]);
                     }

                     loopCount++; //<--increment our loop because we are not done

                     getAllMatchResult(loopCount, response, status); //<--recurse
                 }
                 else
                 {
                     var lines = response.text.split("\n");
                     //lines.splice(lines.length-1, 0, "E0,22/02/2015,West Ham,Crystal Palace,3,5");
                     for(var i = 1; i < lines.length-1; i++){  //start at 1 to avoid the titles, and length-1 to avoid the empty last line
                         var line = lines[i]
                          // use comma as separator
                         var matchScore = line.split(",");
                         if(i == lines.length-2)
                            saveMatchResult(matchScore, matchResults, status);
                        else
                            saveMatchResult(matchScore, matchResults, null);
                     }
                 }
            },
             error: function (error) {
                //badness with the find
             }
         });
}


                      

function shortTeamName(oringinalName){

  var oringinalNameCleare    = oringinalName.replace( /\s/g, "");
        
  return namesDictionary[oringinalNameCleare]
}

function saveMatchResult(matchScore, savedMatches, status){
            
       for(var k = 0; k < allEvents.length; k++){
          
          var matchEvent  = allEvents[k];
          var titleMatch = matchEvent.get("title");
          var array = titleMatch.split(' V ');

          if(array.length > 1){

             var nameHomeTeamEvent = shortTeamName(array[0]);
             var nameAwayTeamEvent = shortTeamName(array[1]);
             
             var nameHomeTeamCSV = shortTeamName(matchScore[2]);
             var nameAwayTeamCSV = shortTeamName(matchScore[3]);

             if(nameHomeTeamEvent == nameHomeTeamCSV && nameAwayTeamEvent == nameAwayTeamCSV){
                
                matchEvent.set("finalScore", matchScore[4] + " - " + matchScore[5])
                matchEvent.save();
             }
          }
       }
          
    var matchScoreAlreadyExist = false;
    for(var i = 0; i < savedMatches.length; i++){ 
          
        var savedMatchScore = savedMatches[i];  
                        
       if(savedMatchScore.get("homeTeam") == matchScore[2] && savedMatchScore.get("awayTeam") == matchScore[3])   {
           matchScoreAlreadyExist = true;
       }
                   
    }

    var MatchResult = Parse.Object.extend("MatchResult");
    if(!matchScoreAlreadyExist){

                     var matchResult = new MatchResult();
          
                      matchResult.set("date", matchScore[1]); 
                      matchResult.set("homeTeam", matchScore[2]); 
                      matchResult.set("awayTeam", matchScore[3]); 
                      matchResult.set("homeTeamScore", matchScore[4]);
                      matchResult.set("awayTeamScore", matchScore[5]);
                      matchResult.save(null, {
                         success: function(object) {
                            if(status != null)   
                               status.success("Done"); 
                          }
                      });
    } else{

      if(status != null)   
           status.success("Done"); 
    }
       
}


var namesDictionary = {"ManchesterUtd":"MUN", "ManUnited":"MUN", "Chelsea":"CHE", "Arsenal":"ARS", "WestBrom":"WBA", "Tottenham":"TOT", "WestHam":"WHU", "Southampton":"SOU", "Liverpool":"LIV", "Swansea":"SWA", "Stoke":"STK",
  "ManchesterCity":"MCI", "ManCity":"MCI", "Newcastle":"NEW", "Everton":"EVE", "CrystalPalace":"CRY", "Hull":"HUL", "Burnley":"BUR", "Sunderland":"SUN", "AstonVilla":"AVL", "QPR":"QPR", "Leicester":"LEI"};


