
Use case for an App accelerator are nicely explained in the following link

Application Accelerator for VMware Tanzu

Instructions to deploy the accelerator as follows

1.	Clone your Git repository.
2.	Create a file named accelerator.yaml in the root directory of this Git repository.
3.	Add the following content to the accelerator.yaml file: - have attached a sample file 
4.	accelerator:
5.	  displayName: Simple Accelerator
6.	  description: Contains just a README
7.	  iconUrl: https://images.freecreatives.com/wp-content/uploads/2015/05/smiley-559124_640.jpg
8.	  tags:
9.	  - simple
10.	  - getting-started
Note: You can use any icon with a reachable URL.
11.	Add the new accelerator.yaml file, commit this change and push to your Git repository.
Publish the new accelerator
To publish the new application accelerator that is created in your Git repository, follow these steps:
1.	Run the following command to publish the new application accelerator:
2.	tanzu accelerator create simple --git-repository YOUR-GIT-REPOSITORY-URL --git-branch YOUR-GIT-BRANCH
Where:
o	YOUR-GIT-REPOSITORY-URL is the URL of your Git repository.
o	YOUR-GIT-BRANCH is the name of the branch where you pushed the new accelerator.yaml file.
3.	Refresh Tanzu Application Platform GUI to reveal the newly published accelerator.
 
