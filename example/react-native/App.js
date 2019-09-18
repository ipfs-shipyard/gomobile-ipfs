/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { Fragment, Component } from 'react';
import WebView from 'react-native-webview';
import {
  StyleSheet,
  SafeAreaView,
  View,
  ActivityIndicator,
  StatusBar,
  NativeModules,
  Text,
} from 'react-native';


const asyncTimeout = time =>
      new Promise(res => setTimeout(res, time))

class App extends Component {
  state = {
    loading: true,
    url: '',
  }

  checkGateway = async () => {
    let res = null
    for (;;) {
      res = await fetch('http://127.0.0.1:5001/webui')
      if (res.ok) {
        this.setState({
          loading: false,
          url: res.url,
        })
        return
      }
      await asyncTimeout(2000)
    }
  }

  startDaemon = async () => {
    try {
      const res = await fetch('http://127.0.0.1:5001/api/v0/id')
      const id = await res.json()
      return id.ID
    } catch (err) {
      console.warn(err)
    }

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
        <View style={[styles.container, styles.horizontal]}>
          <ActivityIndicator size="large" color="#4ca1a3" />
        </View>
      )
    }

    return (
      <Fragment>
          <WebView
            source={{uri: this.state.url}}
            originWhitelist={['*']}
            onError={err => console.warn('webview error:', err)}
          />
      </Fragment>
    );
  };
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
	width: '100%',
	height: '60%',
	position: 'absolute',
	bottom: 0
  },
  horizontal: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 10
  }
})

export default App;
