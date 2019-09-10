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


class App extends Component {
  state = {
    loading: true,
  }

  checkGateway = () => {
    fetch('http://127.0.0.1:5001/webui')
      .then(res => {
        if (res.ok) {
          this.setState({ loading: false })
        } else {
          throw new Error(`gateway unavailable: [${res.status}] ${res.statusText}`)
        }
      }).catch(err => {
        console.warn(err)
        setTimeout(this.checkGateway, 1000)
      })
  }

  componentDidMount() {
    NativeModules.BridgeModule.start()
      .then(() => {})
      .catch(err => console.error(err))
      .then(() => this.checkGateway())
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
        <StatusBar barStyle="dark-content" />
        <SafeAreaView>
          <WebView
            source={{uri: 'http://127.0.0.1:5001/webui'}}
            style={{marginTop: 20}}
          />
        </SafeAreaView>
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
