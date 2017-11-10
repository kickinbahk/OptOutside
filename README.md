# #OptOutside #

OptOutside allows users to connect with Meetup groups who have similar interests of activities.

It uses [Einstein Intent](https://www.salesforce.com/products/einstein/overview/) to take user input (one word to entire phrases) and figure out their request. Read more about the [Einstein API](https://metamind.readme.io/docs/introduction-to-the-einstein-predictive-vision-service)

### Presentation: 
[![Check out the presentation](https://github.com/kickinbahk/OptOutside/blob/master/resources/presentation.png)](https://speakerdeck.com/kickinbahk/optoutside-app)


### Video Demo: 
[![Watch the video](https://github.com/kickinbahk/OptOutside/blob/master/resources/video.png)](https://youtu.be/oQR17lxRhDw)



## Try it Out...
Fork the project or download the zip file. 

### Install the Pods:
Run `pod install` and make sure to add the keys when prompted (See Below). If you don't currently have cocoapods on your machine, follow the instructions [on their website](https://cocoapods.org)

### Keys:
OptOutside doesn't currently have a way to create tokens for the APIs it hits. It uses [Cocoapods-Keys](https://github.com/orta/cocoapods-keys) to store the keys. When you install the projects pods, it will ask you to enter the keys. You should copy and paste these into the console. _Do note: I have had to sometimes run `pod update` a second time adter I added the keys._
 - meetupKey: `5649659726295821a79657a217715`
 - einsteinToken - `NCC3JY33DTLAUB3IHOU2GO27WSRAFPKTWJQ5JGNMABD2QOAUQLTIXUMH5BC37ZWVH5V4GAMWNY2J4RUDJ7UNHWFDLFKDDPW3PR4S4MI`

 ### Open Xcode:
Make sure to open the project using the `OptOutside.xcworkspace` file. Using the `.xcodeproj` file will cause errors. 

1. In Xcode, click on the top level of the project in the Project Navigator (on the left hand side of xcode). 
2. Then, under Targets click on OptOutside. 
3. In the teams section, set the team to your personal team. 

#
You should now be ready to run the app by clicking the Run button at the top of Xcode.
#

##### _For bug, issue and feature tracking, see [Trello Board for OptOutside](https://trello.com/b/70QnQif1/optoutside)_