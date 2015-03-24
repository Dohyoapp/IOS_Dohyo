function clearLog(){

  for(var i = 0; i < 100; i++)
    console.log("");
}

require('cloud/League_functions_V2.js')
require('cloud/Scores_functions.js')
require('cloud/JoinNumber.js')
require('cloud/User_functions.js')
require('cloud/WeekNumber_functions.js')


Parse.Cloud.afterSave("Event", function(request) {

});
