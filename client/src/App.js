import React, { Component } from 'react';
import Web3 from 'web3';
import Token from '../../build/contracts/Token.json'
import EthSwap from '../../build/contracts/EthSwap.json'
import Main from './Main'
import './App.css';

class App extends Component {

  constructor(props){
    super(props)
    this.state = {
      account: '',
      token: {},
      ethSwap: {},
      ethBalance: 0,
      tokenBalance: '0',
      loading: true,
      address: ''
    }
  }

  async componentWillMount() {
    await this.loadWeb3()
    // console.log(window.web3);
    await this.loadBlockdata()
  }

  async loadWeb3(){
    if(window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if(window.web3){
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else{
      window.alert('non etherreum browser');
    }
  }

  async loadBlockdata() {
    const web3 = window.web3
    const accounts = await new web3.eth.getAccounts();
    this.setState({account : accounts[0]});
    // console.log(this.state.account)
    const ethBalance = await web3.eth.getBalance(this.state.account);
    this.setState({ethBalance})
    // console.log(this.state.ethBalance)
    const networkId =  await web3.eth.net.getId()
    const tokenData = Token.networks[networkId]
    if(tokenData) {
      const token = new web3.eth.Contract(Token.abi, tokenData.address)
      this.setState({ token })
      let tokenBalance = await token.methods.balanceOf(this.state.account).call()
      this.setState({ tokenBalance: tokenBalance.toString() })
      // console.log(this.state.tokenBalance)
    } else {
      window.alert('Token contract not deployed to detected network.')
    }

    const ethSwapData = EthSwap.networks[networkId]
    if(ethSwapData) {
      const ethSwap = new web3.eth.Contract(EthSwap.abi, ethSwapData.address)
      this.setState({ ethSwap })
      this.setState({ address : ethSwapData.address })
    } else {
      window.alert('EthSwap contract not deployed to detected network.')
    }
    // console.log(ethSwapData.address)
    this.setState({ loading: false })
  }
  buyTokens = (etherAmount) => {
    this.setState({ loading: true })
    this.state.ethSwap.methods.buyTokens().send({ value: etherAmount, from: this.state.account }).on('transactionHash', (hash) => {
      this.setState({ loading: false })
      this.loadBlockdata();
    })

  }

  sellTokens = (tokenAmount) => {
    this.setState({ loading: true })
    // console.log(this.state.account,this.state.address)
    this.state.token.methods.approve(this.state.address,tokenAmount).send({from: this.state.account}).on('transactionHash', (hash) => {
      this.state.ethSwap.methods.sellTokens(tokenAmount).send({from: this.state.account}).on('transactionHash', (hash) => {
        this.setState({ loading: false })
        this.loadBlockdata();
      })
    })
  }
  

  render() {
    let content
    if(this.state.loading) {
      content = <p id="loader" className="text-center">Loading...</p>
    } else {
      content = <Main
        ethBalance={this.state.ethBalance}
        tokenBalance={this.state.tokenBalance}
        buyTokens={this.buyTokens}
        sellTokens={this.sellTokens}
      />
    }
    return (
      <div>
        <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
          <a
            className="navbar-brand col-sm-3 col-md-2 mr-0"
            href="#"
            target="_blank"
            rel="noopener noreferrer"
          >
            Ethswap
          </a>
          <a>{this.state.account}</a>
        </nav>
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 d-flex text-center">
              {content}
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
// https://github.com/yuvan11/Ethereum-Swap.git
