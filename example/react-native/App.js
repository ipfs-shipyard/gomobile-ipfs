import React, { Component } from 'react'
import WebView from 'react-native-webview'
import {
  StyleSheet,
  SafeAreaView,
  ActivityIndicator,
  NativeModules
} from 'react-native'

class App extends Component {
  state = {
    loading: true,
    url: '',
  }

  asyncTimeout = time =>
      new Promise(res => setTimeout(res, time))

  checkGateway = async () => {
    const api = await this.getApiUrl()
    if (!api || api.length == 0) {
      throw new Error('cannot get api url...')
    }

    const webui = `http://${api[0]}/webui`
    let res = null
    while(42) {
      res = await fetch(webui)
      if (res.ok) {
        this.setState({
          loading: false,
          url: res.url,
        })
        return
      }

      console.warn(`[${res.Status}]: ${res.statusText}`)
      await asyncTimeout(2000)
    }
  }

  getApiUrl = async () => {
    const addrs = await NativeModules.BridgeModule.getApiAddrs()
    if (!addrs) {
      return []
    }

    return addrs.split(',')
  }

  startDaemon = async () => {
    try {
      const api = await this.getApiUrl()
      if (api && api.length > 0) {
        const apiUrl = `http://${api[0]}`
        console.info('api url:', apiUrl)

        const res = await fetch(`${apiUrl}/api/v0/id`)
        const id = await res.json()
        return id.ID
      }
    } catch (err) {
      console.warn('start daemon warn:', err)
    }

    console.info('starting ipfs node')

    await NativeModules.BridgeModule.start()
    return this.startDaemon()
  }

  componentDidMount() {
    this.startDaemon()
      .then(id => console.info('peerID:', id))
      .catch(err => console.error(err))
      .then(this.checkGateway)
  }

  render() {
    if (this.state.loading) {
      return (
        <SafeAreaView style={[styles.spinner_container]}>
          <ActivityIndicator size="large" color="#4ca1a3" />
        </SafeAreaView>
      )
    }

    return (
      <SafeAreaView style={{flex: 1}}>
          <WebView
            source={{uri: this.state.url}}
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
  }
})

export default App
