# Analytics API deployed in Kubernetes
This application has 2 main components.
 - DB Service
 - Analytics API
<br/>
Both of them will be deployed in Kubernetes Cluster. Analytics API will use DB-Service which is a Postgres DB to retrieve data 

### Remote Resources
- AWS CodeBuild - build Docker images remotely
- AWS ECR - host Docker images
- Kubernetes Environment with AWS EKS - run applications in k8s
- AWS CloudWatch - monitor activity and logs in EKS
- GitHub - pull and clone code

## Setup
1. Deploy the application using Codebuild Job -> microservice-app-build-pipeline
 - This will pull the code from github then build and push the docker image to ECR

2. Deploy the Postgres database & Populate Data
 - helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami
 - helm install <DB_SERVICE_NAME> <REPO_NAME>/postgresql
 - export POSTGRES_PASSWORD=$(kubectl get secret --namespace default <DB_SERVICE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
 - echo $POSTGRES_PASSWORD
 - kubectl port-forward --namespace default svc/<DB_SERVICE_NAME>-postgresql 5432:5432 & PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>

3. Run `kubectl describe svc <DB_SERVICE_NAME>` command which gives database info
4. Then get the database info and update the host in db-config map ( if DB_HOST has changed )
5. Also using base 64 encoding, encode the db password retrieved in step 2 and update DB_PASSWORD in db-secret.yaml
6. Update the correct version of ECR image(if changed) in the analytics-api.yaml
7. Deploy the application using following command
 - kubectl apply -f deployments/
8. Run the following command to see all services are running as expected
 - kubectl get pods

## Standout Suggestions
1. Specify reasonable Memory and CPU allocation in the Kubernetes deployment configuration
- For the application we can start with 1 GB memory & 2 vCPUs since it has only few endpoints which are not heavy
- Also, with the demand this will be automatically scaled
- However, with the actual usage stats in cloudwatch, we can reconfigure this later

2. Specify what AWS instance type would be best used for the application? Why?
- Based on the scope of the API and database, T3.Medium instance which is general purpose and also has 4 GB memory, 2 vCPUs seems to be an optimal instance. 
- These instances are medium size which can be horizontally scaled based on the demand which seems to be optimal considering the cost
- But with the time, we can do more analysis, understand about actual memory and CPU usage and come up with an optimal instance type

3. How to save costs
- Starting with a few general purpose medium-sized instances which are not very expensive will reduce the upfront cost 
- but at the same time we can use horizontal scaling to meet the demand if needed
- Implement scale in rules to reduce instances once the usage reduced
- With the cloudwatch stats with the time, we can come up the optimal instance size & instance count