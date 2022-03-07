The dacpac file in this directory is the built output of the project. It is intended for use in automated deployments. (It would be preferable to push the dacpac to an external file store, rather than using the repo itself as the host. However, no such file store has yet been set up for this purpose).

It is built and committed automatically when a change is pushed to the `live` branch, or when the github action is triggered manually.

It can also be built locally. To do this:

- Build the `ntbs-reporting` project in Visual Studio.
- Copy the `ntbs-reporting.dacpac` file from the `source\bin\Output` directory into this one.