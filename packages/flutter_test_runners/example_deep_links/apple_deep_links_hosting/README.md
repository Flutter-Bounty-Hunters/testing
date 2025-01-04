# Apple Deep Link Hosting Website
This directory holds a website with the explicit purpose of hosting a
`apple-app-site-association` file, as required by Apple, to associate
an app with a Universal Link.

This website defines an association for `deeplinks.flutterbountyhunters.com`,
which is used only by `example_deep_links` in this repository. This
association makes it possible for the FBH team to run the iOS deep link
tests locally, and (maybe) run them in CI.

If you're not a member of the FBH team, you won't be able to run the deep
links in this example project, as-is. That's because you can't sign the app,
because you're not a member of our Apple developer organization. If you
want to run the iOS deep link code in this repository, you should do the following:

 1. Change the example app iOS app bundle ID to one that you own, e.g., `com.mydomain.myapp`.
 2. Change the Universal Links in this repo to point to a domain you own, e.g., `https://myapp.mydomain.com`.
 3. (If not done already) Upload an `apple-app-site-association` file to the domain you own.

### Hosting
This website is hosted on Firebase. This was chosen only because it was trivial
to setup, and the configuration can be saved in this directory. It doesn't generally 
matter how the hosting is accomplished.
