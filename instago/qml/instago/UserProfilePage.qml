// *************************************************** //
// User Profile Page
//
// The user profile page shows the personal information
// of the currently logged in user.
// If the user is not logged in, then a link to the
// login process is shown.
// *************************************************** //

import QtQuick 1.1
import com.nokia.meego 1.0

import "js/globals.js" as Globals
import "js/authentication.js" as Authentication
import "js/userdata.js" as UserDataScript

Page {
    // use the detail view toolbar
    tools: profileToolbar

    // lock orientation to portrait mode
    orientationLock: PageOrientation.LockPortrait

    // check if the user is already logged in
    Component.onCompleted: {
        if (Authentication.isAuthenticated())
        {
            // user is authorized with Instagram
            // console.log("User is authorized");

            // show loading indicators while loading user data
            loadingIndicator.running = false;
            loadingIndicator.visible = false;

            // load profile data for user
            var instagramUserdata = Authentication.getStoredInstagramData();
            UserDataScript.loadUserProfile(instagramUserdata["id"]);
        }
        else
        {
            // user is not authorized with Instagram
            // console.log("User is not authorized");

            // activate error container
            userprofileNoTokenContainer.visible = true;
        }
    }

    // standard header for the current page
    Header {
        id: pageHeader
        source: "img/top_header.png"
        text: qsTr("You")
    }


    // container if user is not authenticated
    Rectangle {
        id: userprofileNoTokenContainer

        anchors {
            top: pageHeader.bottom;
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom;
        }

        visible: false;

        // no background color
        color: "transparent"


        // headline
        Text {
            id : userprofileNoTokenHeadline

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: userprofileNoTokenText.top
                bottomMargin: 20
            }

            width: 400

            font.family: "Nokia Pure Text Light"
            font.pixelSize: 25
            wrapMode: Text.WordWrap

            text: "Please log in";
        }


        // description
        Text {
            id : userprofileNoTokenText

            anchors {
                centerIn: parent
            }

            width: 400

            font.family: "Nokia Pure Text"
            font.pixelSize: 20

            wrapMode: Text.WordWrap
            textFormat: Text.RichText

            text: "You are not connected to Instagram,<br />only the public features are available at the moment.<br /><br />Please connect to Instagram to use features like your news stream, following other users<br />or liking other users photos.";
        }


        // login button
        Button {
            id: userprofileNoTokenLogin

            anchors {
                left: parent.left;
                leftMargin: 30;
                right: parent.right;
                rightMargin: 30;
                top: userprofileNoTokenText.bottom;
                topMargin: 30;
            }

            text: "Login"

            onClicked: {
                pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
        }
    }


    // header with the user metadata
    UserMetadata {
        id: userprofileMetadata;

        anchors {
            top: pageHeader.bottom;
            topMargin: 10;
            left: parent.left;
            right: parent.right;
        }

        visible: false

        onProfilepictureClicked: {
            userprofileGallery.visible = false;
            userprofileBio.visible = true;
            userprofileContentHeadline.text = "Your Bio";
        }

        onImagecountClicked: {
            userprofileBio.visible = false;
            userprofileContentHeadline.text = "Your Photos";

            var instagramUserdata = Authentication.getStoredInstagramData();
            UserDataScript.loadUserImages(instagramUserdata["id"], 0);
            userprofileGallery.visible = true;
        }

        onFollowersClicked: {

        }

        onFollowingClicked: {

        }
    }


    // container headline
    // container is only visible if user is authenticated
    Text {
        id: userprofileContentHeadline

        anchors {
            top: userprofileMetadata.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right;
            rightMargin: 10
        }

        height: 30
        visible: false

        font.family: "Nokia Pure Text Light"
        font.pixelSize: 25
        wrapMode: Text.Wrap

        // content container headline
        // text will be given by the content switchers
        text: "Your Bio"
    }


    // user bio
    // this also contains the logout functionality
    UserBio {
        id: userprofileBio;

        anchors {
            top: userprofileContentHeadline.bottom
            topMargin: 10
            left: parent.left
            right: parent.right;
            bottom: parent.bottom
        }

        visible: false
        logoutButtonVisible: true

        onLogoutButtonClicked: {
            Authentication.deleteStoredInstagramData();

            pageStack.clear();
            pageStack.push(Qt.resolvedUrl("PopularPhotosPage.qml"));
        }
    }


    // gallery of user images
    // container is only visible if user is authenticated
    ImageGallery {
        id: userprofileGallery;

        anchors {
            top: userprofileContentHeadline.bottom
            topMargin: 10;
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom;
        }

        visible: false

        onItemClicked: {
            // console.log("Image tapped: " + imageId);
            pageStack.push(Qt.resolvedUrl("ImageDetailPage.qml"), {imageId: imageId});
        }

        onListBottomReached: {
            if (paginationNextMaxId !== "")
            {
                UserDataScript.loadUserImages(userId, paginationNextMaxId);
            }
        }
    }


    // show the loading indicator as long as the page is not ready
    BusyIndicator {
        id: loadingIndicator

        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: "large" }

        running:  false
        visible: false
    }


    // error indicator that is shown when a network error occured
    NetworkErrorMessage {
        id: networkErrorMesage

        anchors {
            top: pageHeader.bottom;
            topMargin: 3;
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom;
        }

        visible: false

        onMessageTap: {
            // console.log("Refresh clicked")
            networkErrorMesage.visible = false;
            userprofileMetadata.visible = false;
            userprofileContentHeadline.visible = false;
            userprofileBio.visible = false;
            loadingIndicator.running = true;
            loadingIndicator.visible = true;
            var instagramUserdata = Authentication.getStoredInstagramData();
            UserDataScript.loadUserProfile(instagramUserdata["id"]);
        }
    }


    // toolbar for the detail page
    ToolBarLayout {
        id: profileToolbar

        // jump back to the popular photos page
        ToolIcon {
            iconId: "toolbar-back";
            onClicked: {
                pageStack.pop();
            }
        }


        // jump to the about page
        ToolIcon {
            iconId: "toolbar-settings";
            onClicked: {
                pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
