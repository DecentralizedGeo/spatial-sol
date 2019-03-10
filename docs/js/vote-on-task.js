var jsonInterface, // load from Project.json ....
  web3,
  project,
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

  $.getJSON('/build/contracts/Project.json', (json) => {
    jsonInterface = json;

    const projectParams = {
      abi: jsonInterface.abi
    };

    project = new web3.eth.Contract(projectParams.abi);

    let latestBlockNum;

    web3.eth.getBlockNumber()
      .then((blockNum) => {
        latestBlockNum = blockNum;
      });

    project.events.allEvents({
        fromBlock: 0
      },
      (error, event) => {
        console.log('YAHHHHH', event);
      });
  });

});


$('#voteOnTask').on('click', (e) => {
  e.preventDefault();
  // console.log(e);

  formData = $("form").serializeArray();
  // process form data
  var deployData = processFormData(formData);
  console.log(deployData);

  // Errors here because we don't have project contract address
  project.methods.voteOnProposedTask(deployData[0], deployData[1])
    .send({
      from: accounts[0]
    })
    .on('receipt', (receipt) => {
      console.log(receipt);
    });
})


// Not a best practice to replicate but we can refactor post MVP ...

function processFormData(_formData) {
  // console.log( _formData);
  // Need this to continue!!
  // project.options.address = _formData[0];
  console.log(_formData);
  var taskId_ = _formData[1].value,
    vote_ = _formData[2].value;

  console.log('adsf', taskId_)

  return (taskId_, vote_);
}
