navigator.serviceWorker
  .register('sw.js').then(function (reg) {
    reg.pushManager.subscribe({
      userVisibleOnly: true
    }).then(function (sub) {
      console.log('subscription:', JSON.stringify(sub));
    }).catch(e => console.log(e));
  }).catch(function (error) {
    console.log('error: ', error);
  });
