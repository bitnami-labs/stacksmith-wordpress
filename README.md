# Generic application with DB (MySQL): WordPress

This is a simple guide to show how to deploy WordPress using [Bitnami Stacksmith](https://stacksmith.bitnami.com).

## Package and deploy with Stacksmith

1. Go to [stacksmith.bitnami.com](https://stacksmith.bitnami.com).
2. Create a new application and select the `Generic application with DB (MySQL)` stack template.
3. Select the targets you are interested on (AWS, Kubernetes,...).
4. Select `Git repository` for the application scripts and paste the URL of this repo. Use `master` as the `Repository Reference`.
5. Click the <kbd>Create</kbd> button.
6. Wait for app to be built and deploy it in your favorite target platform.

Stacksmith will compare the latest commit for a reference (e.g. new commits made to a branch) against the last commit used during packaging. If there are any new commits available, these will be available to view within the `Repository Details` pane in the application history. If you choose to repackage your application, these newer commits will be incorporated and used during the packaging.

## Use the Stacksmith CLI for automating the process

1. Go to [stacksmith.bitnami.com](https://stacksmith.bitnami.com), create a new application and select the `Generic application with DB (MySQL)` stack template.
2. Install [Stacksmith CLI](https://github.com/bitnami/stacksmith-cli) and authenticate with Stacksmith.
3. Edit the `Stackerfile.yml`,  update the `appId` with the URL of your project.
4. Run the build for a specific target like `aws` or `docker`. E.g.

   ```bash
   stacksmith build --target docker
   ```
5. Wait for app to be built and deploy it in your favorite target platform.

## Scripts

In the `stacksmith/user-scripts` folder, you can find the required scripts to build and run this application:

### build.sh

This script takes care of installing the application and its dependencies. It performs the next steps:

* Install Apache and PHP.
* Install [WP-CLI](https://wp-cli.org/).
* Download WordPress.

### boot.sh

This script takes care of configuring the application.

### run.sh

This script takes care of starting the application.
