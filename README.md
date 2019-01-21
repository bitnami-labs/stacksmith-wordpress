[![View in Stacksmith](https://img.shields.io/badge/view_in-stacksmith-00437B.svg)](https://stacksmith.bitnami.com/p/bitnami-public/apps/4f082da0-b4de-0136-ead5-3274f7efdee3)

# Generic application with DB (MySQL): WordPress

This is a simple guide to show how to deploy the latest version of WordPress using [Bitnami Stacksmith](https://stacksmith.bitnami.com).

## Package and deploy with Stacksmith

1. Go to [stacksmith.bitnami.com](https://stacksmith.bitnami.com).
2. Create a new application and select the `Generic application with DB (MySQL)` stack template.
3. Select the targets you are interested on (AWS, Azure, Kubernetes,...).
4. Select `Git repository` for the application scripts and paste the URL of this repo. Use `master` as the `Repository Reference`.
5. Click the <kbd>Create</kbd> button. This will start building an image for the latest available version of WordPress for each of your selected targets.
6. Wait for the latest version of WordPress to be built, and deploy it in your favorite target platform.

Stacksmith will compare the latest commit for a reference (e.g. new commits made to a branch) against the last commit used during packaging. If there are any new commits available, these will be available to view within the `Repository Details` pane in the application history. If you choose to repackage your application, these newer commits will be incorporated and used during the packaging.

## Use the Stacksmith CLI for automating the process

1. Go to [stacksmith.bitnami.com](https://stacksmith.bitnami.com), create a new application and select the `Generic application with DB (MySQL)` stack template.
2. Install [Stacksmith CLI](https://github.com/bitnami/stacksmith-cli) and authenticate with Stacksmith.
3. Edit the `Stackerfile.yml`,  update the `appId` with the URL of your project.
4. Run the build for a specific target like `aws` or `docker`. E.g.

   ```bash
   stacksmith build --target docker
   ```
5. Wait for the latest version of WordPress to be built, and deploy it in your favorite target platform.

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

### Installing plugins

You can add extra plugins by specifing them in the `boot.sh` script:

```bash
readonly plugin_names="akismet all-in-one-wp-migration secure-db-connection"
```

You can also download the zip files in <https://wordpress.org/plugins/> and add them as `Application files` in the Stacksmith UI. Then, Stacksmith will repackage your application with those plugins.

If you are using the Stacksmith CLI, you can add the zip plugin files in the `stacksmith/user-uploads/` directory and reference them in the `Stackerfile.yml`:

```diff
     boot: stacksmith/user-scripts/boot.sh
     run: stacksmith/user-scripts/run.sh
+  userUploads:
+    - stacksmith/user-uploads/jetpack.6.6.1.zip
```

## Persisting the application data

In some applications like WordPress you need to store application data in a persistent storage unit. It allows you to keep the uploaded files and other assets in a safe place if the instance or pod goes down. In these cases, you need to customize the `Generic application with DB (MySQL)` stack template depending on the target that you have choosen.

In the steps below you can find a practical case where you add a persistent volume for Kubernetes. Read more about it here: [Creating a Stack Template](https://stacksmith.bitnami.com/+/support/creating-a-stack-template).

### 1. Download the original Kubernetes Helm Chart template

Go to your application build history view, select the build (Kubernetes Target) that you want to customize and click on <kbd>Download Helm Chart</kbd>.

### 2. Make changes in the Kubernetes Helm Chart template

Unpack the downloaded tarball and edit the following files:

* `values.yaml`

  ```diff
  image:
  -  name: **************************
  +  name: @@IMAGE@@
    pullPolicy: IfNotPresent
  ```

  Add at the end of the file:

  ```diff
  +
  +## Enable persistence using Persistent Volume Claims
  +## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
  +##
  +persistence:
  +  enabled: false
  +  ## wordpress data Persistent Volume Storage Class
  +  ## If defined, storageClassName: <storageClass>
  +  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  +  ## If undefined (the default) or set to null, no storageClassName spec is
  +  ##   set, choosing the default provisioner. (gp2 on AWS, standard on
  +  ##   GKE, AWS & OpenStack)
  +  ##
  +  # storageClass: "-"
  +  ##
  +  ## If you want to reuse an existing claim, you can pass the name of the PVC using
  +  ## the existingClaim variable
  +  # existingClaim: your-claim
  +  accessMode: ReadWriteOnce
  +  size: 10Gi
  ```

* `templates/deployment.yaml`

  At the end of the file, add a `volumeMount` for the WordPress container and define a new volume.

  ```diff
  +        volumeMounts:
  +        - mountPath: /var/www/html/wp-content/
  +          name: wordpress-data
  +      volumes:
  +      - name: wordpress-data
  +      {{- if .Values.persistence.enabled }}
  +        persistentVolumeClaim:
  +          claimName: {{ .Values.persistence.existingClaim | default (include "fullname" .) }}
  +      {{- else }}
  +        emptyDir: {}
  +      {{ end }}
  ```

* Create a new file `templates/pvc.yaml` with the following content:

  ```yaml
  {{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
  kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: {{ template "fullname" . }}
    labels:
      app: {{ template "fullname" . }}
      chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
      release: "{{ .Release.Name }}"
      heritage: "{{ .Release.Service }}"
  spec:
    accessModes:
      - {{ .Values.persistence.accessMode | quote }}
    resources:
      requests:
        storage: {{ .Values.persistence.size | quote }}
  {{- if .Values.persistence.storageClass }}
  {{- if (eq "-" .Values.persistence.storageClass) }}
    storageClassName: ""
  {{- else }}
    storageClassName: "{{ .Values.persistence.storageClass }}"
  {{- end }}
  {{- end }}
  {{- end }}
  ```

### 3. Upload your new custom stack template to Stacksmith

Package the files again as a `tar.gz`. Go to `Settings` > `Stack Templates` > `Create a new stack template` and fill the creation form. Upload the new stack template for the Kubernetes target and click on <kbd>Update</kbd>.

### 4. Build your application with the new stack template

Go to your application and click on <kbd>Edit Configuration</kbd>. Select the new stack template that you have just created and click on <kbd>Update</kbd>.

That's all! Stacksmith will repackage the latest available version of WordPress with your custom stack template. When you want to deploy the new Helm Chart, make sure you enable the persistence. Otherwise, it will behave as the generic stack template:

```bash
helm install yourapp.tgz --set persistence.enabled=true
```
