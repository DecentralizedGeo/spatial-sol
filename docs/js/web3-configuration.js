var jsonInterface, // load from projectFactory ABI ....
  web3,
  projectFactory,
  accounts,
  jsonInterface;

window.addEventListener('load', async () => {
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
      await ethereum.enable();
      web3.eth.sendTransaction({ /* ... */ });
    } catch (error) {
      // throw error;
    }
  } else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
    web3.eth.sendTransaction({ /* ... */ });
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
  }


  (async (w) => {
    accounts = await w.eth.getAccounts();
  })(web3);

  $.getJSON('/build/contracts/ProjectFactory.json', (json) => {
    jsonInterface = json;

    const projectFactoryParams = {
      abi: jsonInterface.abi,
      address: '0x716cb00FC272Bad25A4E39Fdd84cc6231D447E79' // this one can be hard coded but will need to change for testnet or mainnet ......
    };

    projectFactory = new web3.eth.Contract(projectFactoryParams.abi, projectFactoryParams.address);

    let latestBlockNum;

    web3.eth.getBlockNumber()
      .then((blockNum) => {
        latestBlockNum = blockNum;
      });

    projectFactory.events.projectCreated({}, (error, event) => {
        console.log('YAHHHHH', event);
      })
      .on('data', (event) => {
        console.log(event); // same results as the optional callback above
      })
      .on('changed', (event) => {
        // remove event from local database
      })
      .on('error', console.error);;
  });

});
