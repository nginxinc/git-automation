
# git_automation

This is a reference automation for pushing configurations from Git to Nginx Instance Manager, that allows a user to manage configurations for instances and instance groups keeping Git as the source of truth.

## Requirements

- bash shell
- Installed Nginx Instance Manager with atleast one Instance and Instance Group.

## How to Use

1. To clone this repository, 

	```
	git clone https://github.com/nginxinc/git-automation.git
	```

2. Once you have cloned the repository, modify the following variables in `gitlab-ci.yaml` file:
   	```
	CTRL_IP - IP for Nginx Instance Manager.
	AUTH_TOKEN - Authorization token for connecting to Nginx Instance Manager.
	SYSTEM_UID - System UID of the instance to push configuration changes.
	NGINX_UID - Nginx UID of the instance to push configuration changes.
	GROUP_UID - Instance Group UID of the instance group to push configurations changes.
3. This repository has sample script files to create payload for instances [prepare-payload.sh](https://github.com/nginxinc/git-automation/blob/main/prepare-payload.sh "prepare-payload.sh") and instance groups [prepare-instGroup-payload.sh](https://github.com/nginxinc/git-automation/blob/main/prepare-instGroup-payload.sh "prepare-instGroup-payload.sh") 

	Usage example for [prepare-payload.sh](https://github.com/nginxinc/git-automation/blob/main/prepare-payload.sh "prepare-payload.sh") :

	```
	./prepare-payload.sh ${CTRL_IP} ${AUTH_TOKEN} ${SYSTEM_UID} ${NGINX_UID}
	```

	Usage example for [prepare-instGroup-payload.sh](https://github.com/nginxinc/git-automation/blob/main/prepare-instGroup-payload.sh "prepare-instGroup-payload.sh") :

	```
	./prepare-instGroup-payload.sh ${CTRL_IP} ${AUTH_TOKEN} ${GROUP_UID}
	```


  
4. Once you commit, push your changes upstream a separate pipeline should be triggered for instance or instances groups depending if changes are made in the config files for it. You can specify the default path for config files using environment variables. 
	```
	DEFAULT_INSTANCE_CONFIG_FILE_PATH : Config file location for Instances.
	DEFAULT_INSTANCE_GROUP_CONFIG_FILE_PATH: Config file location Instance Groups.
	```

5. Once the pipeline is triggered, it will create a valid payload with `externalId` set as the git commit ID  and send a `POST` request to Nginx Instance Manager to apply the new configuration changes.
  

## Contributing

  

Please see the [contributing guide](https://github.com/nginxinc/git-automation/blob/main/CONTRIBUTING.md) for guidelines on how to best contribute to this project.

  

## License

  

[Apache License, Version 2.0](https://github.com/nginxinc/git-automation/blob/main/LICENSE)

  

&copy; [F5, Inc.](https://www.f5.com/) 2023
