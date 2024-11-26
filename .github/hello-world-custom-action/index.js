const core = require('@actions/core');

async function run() {
  try {
    // Get the input from the workflow
    const nameToGreet = core.getInput('who-to-greet');
    const time = new Date().toISOString();

    // Log the greeting message
    console.log(`Hello, ${nameToGreet}!`);
    console.log(`The time is ${time}`);

    // Set an output for the action
    core.setOutput('greeting-time', time);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
