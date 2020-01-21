import React, { Component } from 'react'
import WebView from 'react-native-webview'
import base64 from 'base-64'
import Multiaddr from 'multiaddr/dist/index.min'
import queryString from 'query-string'
import {
  StyleSheet,
  SafeAreaView,
  ActivityIndicator,
  NativeModules
} from 'react-native'

class App extends Component {
  state = {
    loading: true,
    webui: '',
  }

  _asyncTimeout = time =>
      new Promise(res => setTimeout(res, time))

  // Native Call to ipfs through react native bridge
  _IpfsShell = (command, params = {}, body = "") => {
    const query       = queryString.stringify(params)
    const uri         = query.length ? `${command}?${query}` : command
    const encodedBody = base64.encode(body)

    console.info('calling:', uri)
    return NativeModules.BridgeModule.fetchShell(uri, encodedBody)
      .then(encoded => base64.decode(encoded))
      .then(res => JSON.parse(res))
  }

  // Get API url through IPFS Config
  _getApi = async () => {
    const res = await this._IpfsShell('/config', { arg: 'Addresses.API'})
    const addrs = res.Value

    for (let i = 0; i < addrs.length; ++i) {
      try {
        const maddr     = new Multiaddr(addrs[i])
        const addr      = maddr.nodeAddress()
        const api       = `http://${addr.address}:${addr.port}`

        console.info('api uri found from config:', api)
        return this.setState({
          loading: false,
          webui: `${api}/webui`,
        })
      } catch (err) {
        console.warn(`${addrs[i]}, is not supported by js-multiaddr library: ${err.message}`)
      }
    }

    throw new Error('no valid addrs found for fetching WebUI')
  }

  // start ipfs node
  _startDaemon = async () => {
    try {
      // is ipfs node already running ?
      const id = await this._IpfsShell('/id')
      console.info('ipfs node:', id)
      return id.ID
    } catch (err) {
      console.warn('start daemon warn:', err.message)
    }

    console.info('starting ipfs node!')

    await NativeModules.BridgeModule.start()
    await this._asyncTimeout(1000)

    // try to fetch api again
    return this._startDaemon()
  }

  componentDidMount() {
    this._startDaemon()
      .then(id => console.info('peerID:', id))
      .catch(err => console.error(err))
      .then(this._getApi)
      .catch(err => console.warn('failed to get api url:', err.message))
  }

  render() {
    const { loading } = this.state

    if (loading) {
      return (
        <SafeAreaView style={[styles.spinner_container]}>
          <ActivityIndicator size="large" color="#4ca1a3" />
        </SafeAreaView>
      )
    }

    return (
      <SafeAreaView style={{flex: 1}}>
        <WebView
          source={{uri: this.state.webui}}
          originWhitelist={['*']}
          mediaPlaybackRequiresUserAction={false}
          allowFileAccess={true}
          onMessage={msg => console.log('webview message:', msg)}
          onError={err => console.warn('webview error:', err)}
        />
      </SafeAreaView>
    )
  }
}

const styles = StyleSheet.create({
  spinner_container: {
    flex: 1,
    justifyContent: 'center',
    width: '100%',
    height: '60%',
    position: 'absolute',
    bottom: 0
  },
})

export default App
