## Media namespace Helm releases

All media apps use the bjw-s/app-template chart.

Chart repo: bjw-s  
Chart: app-template  
Version pinned: 4.5.0

### Releases
- jellyfin (media) chart=app-template@4.5.0 values=helm/media/jellyfin.values.yaml
- sonarr (media) chart=app-template@4.5.0 values=helm/media/sonarr.values.yaml
...


## recreate-media-stack
```
helm repo add bjw-s https://bjw-s.github.io/helm-charts
helm repo update

helm upgrade --install jellyfin bjw-s/app-template -n media -f helm/media/jellyfin.values.yaml
```