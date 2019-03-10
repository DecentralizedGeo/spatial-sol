const {
  BN,
  expectEvent,
  shouldFail,
  constants,
  balance,
  send,
  ether
} = require("openzeppelin-test-helpers");

const Project = artifacts.require("Project");

contract('Project', (accounts) => {
  let projectInstance;

  const projectConstructorParams = {
    gihubRepo: "self-sovereign-organization",
    address: accounts[0],
    adminName: 'Isaac',
    adminGithubUsername: 'isaacsultan',
    projectPurpose: 'to build a website',
    voteInterface: accounts[9], // I think we need to drop this ...
    votePercentage: 100,
    projectNum: 1
  }

  beforeEach(async function () { // need async here?
    projectInstance = await Project.deployed(...Object.values(projectConstructorParams));
  });

  it('first test', async () => {

    const ghRepo = 'repo';
    // projectInstance = await Project.deployed();

    const githubRepo = await projectInstance.githubRepo.call(accounts[0]);
    assert.equal(ghRepo, githubRepo, "githubRepo successfully set");
  });

  it('should register a new participant', async () => {

    await projectInstance.addParticipant(accounts[1]);
    assert.equal(projectInstance.participants(accounts[1]).)
  });

  it('should return a taskId', async () => {

  //  projectInstance = await Project.deployed();
      const taskProposal = await projectInstance.proposeTask(accounts[2], BN(1000000), "gitCommit", 1000000000, 10000, 50);
      assert.equal(await projectInstance.tasks.call(accounts[0], ).taskId, taskProposal, "Task was not written to mapping properly.") // how to get mapping value ...?
  });

  it('should register a participant\'s vote', async () => {

  //  projectInstance = await Project.deployed();
    const taskId = await projectInstance.proposeTask(accounts[2], BN(1000000), "gitCommit", 1000000000, 10000, 50)
    await projectInstance.voteOnProposedTask(taskId, 1);
    assert.equal(await projectInstance.ttasks.call(accounts[0], ))
  });


  it('should successfully accept a task', async () => {

  });

  it('should accept evidence submission and initiate ballot', async () => {

  });

});
