# AWS RDS with SQL Server with un/pw on demand

## Overview
POC project with LocalStack to determine best way to configure this with terraform and test

![Proof of concept Diagram](images/rds-lambda-rotation.drawio.png)

1. **<span style="color:blue">Blue Line</span>** -> AWS Secrets manager triggers rotation based on schedule, triggers lambda to rotate password, saves new password
2. **<span style="color:green">Green Line</span>** -> Lambda Function Connects to database with current primary master credentials, and rotates password for user account.
3. **<span style="color:orange">Orange Line</span>** -> Test Application Gets the credentials on startup from aws secrets manager
4. **<span style="color:purple">Purple line</span>** -> Test Application connects to Database using retrieved secrets


