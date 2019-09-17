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
} from 'react-native';


const asyncTimeout = (cb, time) =>
      new Promise(res => setTimeout(cb, time))

class App extends Component {
  state = {
    loading: true,
    url: '',
  }

  checkGateway = async () => {
    try {
      const res = await fetch('http://127.0.0.1:5001/webui')
      if (res.ok) {
        console.warn(res.url)
        this.setState({
          loading: false,
          url: res.url,
        })
      }
    } catch (err) {
      console.warn(err)
      return asyncTimeout(this.checkGateway, 2000)
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
      .catch(err => console.Warn(err))
  }

  render() {
    if (this.state.loading) {
      return (
        <View style={[styles.container, styles.horizontal]}>
          <ActivityIndicator size="large" color="#0000ff" />
        </View>
      )
    }

    return (
      <Fragment>

          <WebView
            source={{uri: this.state.url}}
            originWhitelist={['*']}
            onError={err => console.warn(err)}
            onMessage={msg => console.log(msg)}

          />
      </Fragment>
    );
  };
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center'
  },
  horizontal: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 10
  }
})

export default App;
