// Copyright 2021 Google LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import React, { useEffect, useState, useContext } from 'react'
import { Space, ComponentsProvider, Span } from '@looker/components'
import { ExtensionContext } from '@looker/extension-sdk-react'

/**
 * A simple component that uses the Looker SDK through the extension sdk to display a customized hello message.
 */

export const HelloWorld = () => {
  const { core40SDK } = useContext(ExtensionContext)
  const [message, setMessage] = useState()

  useEffect(() => {
    const initialize = async () => {
      try {
        const value = await core40SDK.ok(core40SDK.me())
        setMessage(`Logged in as ${value.display_name}`)
      } catch (error) {
        setMessage('Error occured getting information about me!')
        console.error(error)
      }
    }
    initialize()
  }, [])

  return (
    <>
      <ComponentsProvider>
        <Space around>
          <Span fontSize="small">
            {message}
            <p></p>
            <p></p>
            
            <div class="todays-news">
    <div class="container">
        <div class="owl-carousel owl-theme">
            <div class="item">
                <div class="card" onclick="this.querySelector('a').click(); return true;">
                  <img src="https://lh6.googleusercontent.com/qRhO1G90fbaSysaaDILKNY-7Df17oft_ADoA4tC6HBWeiOtppIwWk5I3QvseSQxKUeY=w2400" width="11%" height="auto"/>
                  <div class="card-body">
                    <strong>Inventory and Products:  </strong><a href="https://hack.looker.com/dashboards/47">Inventory Dashboard</a>
                    <p>Use this dashboard to monitor inventory levels and order status</p>
                    <strong><a href="https://hack.looker.com/dashboards/40">Alerting Dashboard</a></strong>
                    <p></p>
                  </div>
                </div>
            </div>
            <img src="https://lh4.googleusercontent.com/lZ0vphrwi-SSdcjmUbbHqbEOjU1XZS9zgbGuUhPkjjIq6YkDsps4anHwulCYAE9Ly_Y=w2400" width="27%" height="auto"/>
            <div class="item" onclick="this.querySelector('a').click(); return true;">
                <div class="card">
                  <img src="https://lh6.googleusercontent.com/qRhO1G90fbaSysaaDILKNY-7Df17oft_ADoA4tC6HBWeiOtppIwWk5I3QvseSQxKUeY=w2400" width="11%" height="auto"/>
                  <div class="card-body">
                    <strong>Set up Real-Time Alerting:  </strong><a href="https://hack.looker.com/dashboards/47">Inventory Dashboard</a>
                     <p>Use this dashboard to monitor inventory levels and order status</p>
                     <strong><a href="https://hack.looker.com/dashboards/40">Alerting Dashboard</a></strong>
                  </div>
                </div>
            </div>
        </div>

    </div>
</div>
          </Span>
        </Space>
      </ComponentsProvider>
    </>
  )
}
