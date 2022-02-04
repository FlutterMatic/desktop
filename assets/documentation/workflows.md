## Workflows with FlutterMatic
Running repetitive tasks with FlutterMatic is easy. Workflows is made to be a simple tool that you can program to run a sequence of commands for a specific project. Note that this does not replace more advanced and complex integration tools such as GitHub Actions, CodeMagic, or other CI/CD tools.

## pubspec.yaml Requirements
When adding a workflow to a project, we will ask for the `pubspec.yaml` file for that project. This is used to determine the project's information, whether it is a Flutter project or not, etc. There are requirements for the `pubspec.yaml` file to be able to add a workflow:
  - Must contain a `name`
  - Must contain an `environment` section. This is used to define the Dart version. Also can be used to determine whether or not null safety is enabled.

## Running Workflows
Workflows are easy to run. When running a workflow, we will show a visual of the current action that is being executed. This will help you understand what is happening. At the same time, we will be logging the outcomes of each action so that you can view the detailed logs in case the workflow fails.

## Workflow Sessions
Each time you run a workflow, it is considered a workflow session. This means that there will be a file stored locally in your project that the workflow is for, which contains all the information about what happens since that workflow session started. Each workflow has its folder which contains all of that workflow-specific sessions. You can easily browse them and see what happened in each session. You also have the option to delete session information that is older than 30 days or manually delete a session.