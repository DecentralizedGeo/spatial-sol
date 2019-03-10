// Web3 setup


var jsonInterface, // load from projectFactory ABI ....
  web3,
  project,
  projectOptions,
  accounts,
  jsonInterface,
  coords;

window.addEventListener('load', async () => {
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
      await ethereum.enable();
      console.log("ETHEREUM ENABLED");
      // web3.eth.sendTransaction({ /* ... */ });
    } catch (error) {
      // throw error;
    }
  } else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
    // web3.eth.sendTransaction({ /* ... */ });
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
  }


  (async (web3) => {
    accounts = await web3.eth.getAccounts();

  })(web3);

  navigator.geolocation.getCurrentPosition(function (position) {
    lon = Math.floor(position.coords.longitude * 10**6);
    lat = Math.floor(position.coords.latitude * 10**6);
    coords = [lon, lat];
  });



  $.getJSON('..//build/contracts/LocationAware.json', (json) => {
    jsonInterface = json;

    locationAwareOptions = {
      abi: jsonInterface.abi,
      data: jsonInterface.bytecode,
    };


    locationAware = new web3.eth.Contract(locationAwareOptions.abi, null, locationAwareOptions);

  });

  $('#deploy').on('click', function (e) {
    e.preventDefault();
    var formData = $("form").serializeArray();
    console.log(formData);
    var toAddress = formData[0].value;
    var txValue = web3.utils.toWei(formData[1].value);
    locationAware.options.address = formData[2].value;
    // coords = [2318328, 48896719];

    locationAware.methods.sendWithLocationChecks(toAddress, coords, txValue)
      .send({from: accounts[0]}, (error, transactionHash) => {
        if (error) throw error;
        console.log(transactionHash);

        window.open('https://ropsten.etherscan.io/tx/' + transactionHash, "_blank");
      })
      .on('receipt', (receipt) => {
        console.log(receipt);
      });

  })

});
