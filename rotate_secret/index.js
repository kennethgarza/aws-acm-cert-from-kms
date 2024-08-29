const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();
const rds = new AWS.RDS();

exports.handler = async (event) => {
    const secretArn = event.SecretId;
    const clientRequestToken = event.ClientRequestToken;
    const step = event.Step;

    const metadata = await secretsManager.describeSecret({ SecretId: secretArn }).promise();
    if (metadata.RotationEnabled && metadata.VersionIdsToStages[clientRequestToken].includes("AWSCURRENT")) {
        console.log("Secret version already set as AWSCURRENT");
        return;
    }

    switch (step) {
        case "createSecret":
            await createSecret(secretArn, clientRequestToken);
            break;
        case "setSecret":
            await setSecret(secretArn, clientRequestToken);
            break;
        case "testSecret":
            await testSecret(secretArn, clientRequestToken);
            break;
        case "finishSecret":
            await finishSecret(secretArn, clientRequestToken);
            break;
        default:
            throw new Error(`Unknown step: ${step}`);
    }
};

async function createSecret(secretArn, clientRequestToken) {
    const secretValue = await secretsManager.getSecretValue({ SecretId: secretArn, VersionStage: "AWSCURRENT" }).promise();
    const currentSecret = JSON.parse(secretValue.SecretString);

    const newPassword = generateStrongPassword(50);
    const newSecret = {
        username: currentSecret.username,
        password: newPassword
    };

    await secretsManager.putSecretValue({
        SecretId: secretArn,
        ClientRequestToken: clientRequestToken,
        SecretString: JSON.stringify(newSecret),
        VersionStages: ["AWSPENDING"]
    }).promise();
}

async function setSecret(secretArn, clientRequestToken) {
    const secretValue = await secretsManager.getSecretValue({ SecretId: secretArn, VersionStage: "AWSPENDING", VersionId: clientRequestToken }).promise();
    const pendingSecret = JSON.parse(secretValue.SecretString);

    // Update the RDS instance with the new password
    await rds.modifyDBInstance({
        DBInstanceIdentifier: "test-instance",
        MasterUserPassword: pendingSecret.password,
        ApplyImmediately: true
    }).promise();
}

async function testSecret(secretArn, clientRequestToken) {
    const secretValue = await secretsManager.getSecretValue({ SecretId: secretArn, VersionStage: "AWSPENDING", VersionId: clientRequestToken }).promise();
    const pendingSecret = JSON.parse(secretValue.SecretString);

    // Test the new password by connecting to the database
    // Implement your database connection logic here
}

async function finishSecret(secretArn, clientRequestToken) {
    await secretsManager.updateSecretVersionStage({
        SecretId: secretArn,
        VersionStage: "AWSCURRENT",
        MoveToVersionId: clientRequestToken,
        RemoveFromVersionId: metadata.VersionIdsToStages["AWSCURRENT"][0]
    }).promise();
}

function generateStrongPassword(length = 12) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const specialChars = '!@#$%^&*()_+[]{}|;:,.<>?';

    const allChars = uppercase + lowercase + numbers + specialChars;
    let password = '';

    // Ensure the password contains at least one character from each category
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += specialChars[Math.floor(Math.random() * specialChars.length)];

    // Fill the rest of the password length with random characters from all categories
    for (let i = password.length; i < length; i++) {
        password += allChars[Math.floor(Math.random() * allChars.length)];
    }

    // Shuffle the password to ensure randomness
    password = password.split('').sort(() => 0.5 - Math.random()).join('');

    return password;
}