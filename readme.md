# Netlify in practice

A comprehensive "intro to Netlify" video.

google-fu
inurl:ftp inurl:web.config filetype:config

Part 1: Netlify Edge https://youtu.be/gGjRrjz0KVE
Part 2: Netlify Build https://youtu.be/d3TQUan1UTk
Part 3: Netlify Dev https://youtu.be/2FstPfDizZY
Part 4: Netlify Forms https://youtu.be/XbtJaSduuyQ
Part 5: Netlify Identity https://youtu.be/fIOxUy-2rxw
Part 6: NetlifyCMS https://youtu.be/Sl2kF-7w6G0
Part 7: Netlify Addons https://youtu.be/Ht9WUloWTlg
Part 8: Netlify API https://youtu.be/9_4Bfg8MoNM
Part 9: Learn More https://youtu.be/CaVmJIfzR7k

## Deploy

- 4 methods

  - Netlify Drop

  - Netlify CLI
  
    - Installation:
    
      `yarn global add netlify-cli`
      or `npm i -g netlify-cli`

    - Initialization:

     `netlify init`
     
     No git remote was found, would you like to set one up?
     
     It is recommended that you initialize a site that has a remote 
     repository in GitHub.
     
     This will allow for Netlify Continuous deployment to build branch & PR previews.
     
     For more details on Netlify CI checkout the docs: http://bit.ly/2N0Jhy5
     
     ? Do you want to create a Netlify site without a git repository? 
     No, I will connect this directory with GitHub first
     
     To initialize a new git repo follow the steps below.
     
     1. Initialize a new repo:
     
        `git init`
     
     2. Commit your files
     
        `git add .`
     
     3. Commit your files
     
        `git commit -m 'initial commit'`
     
     4. Create a new repo in GitHub https://github.com/new
     
     5. Link the remote repo with this local directory
     
        `git remote add origin git@github.com:YourGithubName/your-repo-slug.git`
     
     6. Push up your files
     
        `git push -u origin main`
     
     7. Initialize your Netlify Site
     
        netlify init

    ```
    - Login:
      `netlify login` or `ntl login`
    - Deploy:
      `ntl deploy`
    - All commands: `netlify help`
    
    Netlify command line tool

    VERSION
      netlify-cli/3.30.2 wsl-x64 node-v14.16.1
    
    USAGE
      $ netlify [COMMAND]
    
    TOPICS
      addons      (Beta) Manage Netlify Add-ons
      completion  (Beta) Generate shell completion script
      dev         Local dev server
      env         (Beta) Control environment variables for the current site
      functions   Manage netlify functions
      lm          Handle Netlify Large Media operations
      open        Open settings for the site linked to the current folder
      plugins     list installed plugins
      sites       Handle various site operations
      status      Print status information
    
    COMMANDS
      addons      (Beta) Manage Netlify Add-ons
      api         Run any Netlify API method
      build       (Beta) Build on your local machine
      completion  (Beta) Generate shell completion script
      deploy      Create a new deploy from the contents of a folder
      dev         Local dev server
      env         (Beta) Control environment variables for the current site
      functions   Manage netlify functions
      help        Display help. To display help for a specific command run `netlify help [command]`
      init        Configure continuous deployment for a new or existing site
      link        Link a local repo or project folder to an existing site on Netlify
      lm          Handle Netlify Large Media operations
      login       Login to your Netlify account
      open        Open settings for the site linked to the current folder
      plugins     list installed plugins
      sites       Handle various site operations
      status      Print status information
      switch      Switch your active Netlify account
      unlink      Unlink a local folder from a Netlify site
      watch       Watch for site deploy to finish
    
  - Continuous Deploy to Netlify
    - Deploy Hooks
    - Private repos https://community.netlify.com/t/commo...
  - Deploy to Netlify Button
    - JAM-stack templates https://templates.netlify.com/
    - more ways (Siri, Wand, Watch, CodeSandbox) https://community.netlify.com/t/commo...

- Functions
  - add a sample JS and Go function
  - setting Functions folder in app
  - setting Functions folder in netlify.toml
  - Event Triggered Functions
    - `deploy-building`, `deploy-succeeded`, `deploy-failed`, `deploy-locked`, `deploy-unlocked`
    - Env variables
      - INCOMING_HOOK_TITLE, INCOMING_HOOK_URL, INCOMING_HOOK_BODY https://www.netlify.com/docs/webhooks...
  - AWS Lambda versions: AWS_LAMBDA_JS_RUNTIME nodejs >= 10.x

- Defaults
  - [HTTPS](https://www.netlify.com/docs/ssl/)
  - [Deploy Previews](https://www.netlify.com/docs/continuo...)
    - [Branch deploys](https://www.netlify.com/docs/continuo...)
    - Split testing
      - `split-test-activated`, `split-test-deactivated`, `split-test-modified`

  - Distributed Deploys, Atomic Deploys, Instant Rollbacks
  
- Post Processing
  - Forms 
  - Mixed Content
  - Prerendering https://www.netlify.com/docs/prerende...
  - [Asset Optimization](https://www.netlify.com/blog/2019/08/...)
    - Netlify Large Media
    - https://www.netlify.com/docs/large-me...
  - Snippet Injection
    - for GA, eg its more involved if you do it in Nuxt
- Netlify and Custom Domains
  - Custom Netlify Domain
  - Redirects
    - `_redirects` file
    - netlify.toml version
    - https://play.netlify.com/redirects
  - Headers
    - `_headers` file
    - netlify.toml version
    - https://play.netlify.com/headers
    - Cache control https://www.netlify.com/docs/headers-...
    - Auth headers https://www.netlify.com/docs/headers-...
  - [Custom Domains](https://www.netlify.com/docs/custom-d...)
  - Netlify DNS
    - https://www.netlify.com/docs/dns/
    - https://community.netlify.com/t/commo...
    - https://community.netlify.com/t/commo...
  - Emails https://community.netlify.com/t/commo...
- CDN Tips
  - Faster deploys https://community.netlify.com/t/commo...
  - Enterprise https://community.netlify.com/t/commo...
