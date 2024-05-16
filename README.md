## DevOps Engineer Home Assignment
Below is a home assignment for a DevOps Engineer position. You are requested to:
1. Understand the requirements and use case. You may contact the interviewer for further clarification.
2. Implement and run your deployment plan for backend environment using the most efficient tools.
3. Present your deployment and result in the next interview session.

### Requirements
You are a DevOps engineer in a project of building an online orders system. Your task is to deploy a prototype created by the development team and make it available on the public internet.

Below is the information given by the development team.

### Global Environment Requirement
- Start a MongoDB instance, it should be reachable by the prototype code and the development team
- Started MongoDB instance using this [chart](https://github.com/BoazHalter/vi/tree/master/mongodb) with complete documentation from https://artifacthub.io/packages/helm/bitnami/mongodb

### Backend Requirements
- NodeJS LTS version
- Set environment variable `MONGODB_URL="<mongodb connection url>"`, where `<mongodb connection url>` must match the [official mongodb node driver uri]        
  (https://docs.mongodb.com/drivers/node/current/fundamentals/connection/#connection-uri)
- Navigate to package(s) directory `cd packages/<package>`
- Build using npm `npm install`
- Start using node `node index.js`
- Created a GitHub action based for each service1 and service2 [CI procedure](https://github.com/BoazHalter/vi/actions/workflows/node-service1.js.yml) to store the artifacts in ECR

### Cloud Infrastructure Requirement
Your deployment must meet the following criteria:
- A working deployment which reachable through internet
  ```
    curl -XPOST http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service1 -d '{}'
    Order number 19 created successfully.

    curl -XDELETE http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service1/4
    Order number 4 deleted successfully.

    curl -XGET http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service2
    [{"_id":1},{"_id":3},{"_id":6},{"_id":7},{"_id":8},{"_id":9},{"_id":10},{"_id":11},{"_id":12},{"_id":13},{"_id":14},{"_id":15},{"_id":16},{"_id":17},{"_id":18},      
    {"_id":19}]

  ```
- IaC (Infrastructure as Code) deployment for the created AWS resources. You may use Cloudformation, Terraform or AWS CDK for that purpose
- Created eks cluster using [Terraform](https://github.com/BoazHalter/vi/tree/master/learn-terraform-provision-eks-cluster-main) with complete documentation from       
  https://github.com/hashicorp/learn-terraform-provision-eks-cluster
- Documentation for the deployment plan and the resources created

### Guidebook on completing the assignment
- Your implementation should be commited to your own public git repository, including any IaC, documentation, etc (fork this repository)
- [Forked from](https://github.com/vi-technologies/devops-assignment) into [The current repo](https://github.com/BoazHalter/vi) 
- Create dockerfiles to match the deployment requirements
- Created Dockerfile foreach [service1](https://github.com/BoazHalter/vi/blob/master/packages/service1/Dockerfile) and [service2](https://github.com/BoazHalter/vi/blob/master/packages/service2/Dockerfile)
- Create all resources using IaC tools
- Use [Amazon Elastic Container Registry](https://us-east-1.console.aws.amazon.com/ecr/get-started) to push the images to a private repository
- Created [Amazon Elastic Container Registry](https://github.com/BoazHalter/vi/tree/master/terrafrom-ecr) Using [This](https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples/complete) repo with complete documentation
- Create a [Kubernetes](https://us-east-1.console.aws.amazon.com/eks/home) cluster
- Use helm to deploy the service(s)
- Create a MongoDB instance and make it reachable for the deployed service, update the `MONGODB_URL` environment variable to match the mongodb connection url 
- Expose the services to the internet using AWS Load Balancer, AWS Elastic IP, and Network Interface
- Document the deployment steps and the resources created in the deployment as clear and detailed as possible
- Bonus (implement or write detailed plan):
  - Supply the deployment with CI/CD automated process to push the image to ECR and deploy it to the cluster
  - Monitor the service and handle recovery for different resources
  - Maintain and handle the scaling of the service
  - Maintain and handle high availability of the service according to best practices
  - Secure the deployments according to best practices (rate limits, relevant security groups, etc)
  - Consider multi-tenant and multi-environment deployment 
  - Documentation for disaster recovery plan
  - Any other improvement that you think is relevant for this project
### Guidebook

```
  1.forked the original repo
  2.created github actions to build the services1/2.
  3.created ecr using the terraform-ecr:
  4.Uploaded the eks terrafrom directory to the current repo
  5.made some modification to main.tf changed name of cluster ,vpc,region etc...
  6.inside the eks-terraform directory ran the following :
    - terraform init
    - terraform plan -out tfplan
    - terraform apply "tfplan"
  7.cluster created with all best-practices asg , private subnet, public subnet , multi az's etc...
  8.updated kube-config.
    - aws eks update-kubeconfig  --name vi-eks-5mHLrn1W 
  9.installing nginx-ingress-controller chart
  10.downloaded the chart values and modified it to deploy as daemonset ruther than deployment.
  11.deployed the ingress-nginx chart:
    - helm upgrade -f values.yaml -i ingress-nginx ingress-nginx/ingress-nginx \
      --namespace kube-system \
      --set controller.service.type=LoadBalancer
    - helm upgrade -i ingress-nginx -f values.yaml \
      ingress-nginx/ingress-nginx     \
      --namespace kube-system \
      --set controller.watchIngressWithoutClass=true
    
  12.ingress-nginx installed and Load balancer created.
  13.installed mongodb
     -  helm install mongodb ./mongodb
  14.mongodb started. 
     - export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)
  15.installed service1 and service2 using helm chrat i created
     helm install service1 --set password=$MONGODB_ROOT_PASSWORD  \
     --set username=root    ./packages/service1/service1-chart/
     helm install service2 --set password=$MONGODB_ROOT_PASSWORD  \
     --set username=root    ./packages/service2/service2-chart/
  16.services deployed
  17.testing:
     - curl -XPOST http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service1 -d '{}'
       Order number 19 created successfully.

     - curl -XDELETE http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service1/4
       Order number 4 deleted successfully.

     - curl -XGET http://a8757eb4642ab45548b64a13c632eea4-1896208677.eu-central-1.elb.amazonaws.com/service2
       [{"_id":1},{"_id":3},{"_id":6},{"_id":7},{"_id":8},{"_id":9},{"_id":10},{"_id":11},{"_id":12},{"_id":13},{"_id":14},{"_id":15},{"_id":16},{"_id":17},{"_id":18},      
       {"_id":19}]
   
  ``` 
    
### How will the assignment be evaluated
When evaluating the assignment, we will consider the following:
- The deployment plan and the resources are created and working as expected. We will trigger the API and expect a valid response
- The documentation is clear and detailed, we will follow the documentation to understand the deployment process
- Best practicies are followed across all functional and non-functional requirements (for example: security, cost optimization, reliability, etc)

### General Notes
- For performing the assignment, you will be given with AWS credentials (console and programmatic) to a dedicated account, **DO NOT COMMIT THEM IN THE CODE**
- Make sure to create small tier resources, as the prototype demands minimal working loads
- This assignment can be implemented in more than one way, if any further permissions are required for your implementation, contact us
- If you have any other questions, please do not hesitate to ask
