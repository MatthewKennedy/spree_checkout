// import Uri from 'jsuri'

// const SpreeCheckout = {}

// if (!window.SpreeCheckout) { window.SpreeCheckout = SpreeCheckout }

// SpreeCheckout.mountedAt = function () { return window.SpreePaths.mounted_at }
// SpreeCheckout.adminPath = function () { return window.SpreePaths.admin }

// SpreeCheckout.pathFor = function (path) {
//   const locationOrigin = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '')
//   return this.url('' + locationOrigin + this.mountedAt() + path, this.url_params).toString()
// }
const SpreeCheckout = {}

if (!window.SpreeCheckout) { window.SpreeCheckout = SpreeCheckout }

const platformApiMountedAt = function () { return window.SpreeCheckout.paths.platform_api_mounted_at }

const pathFor = function (path) {
  const locationOrigin = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '')
  const queryParts = window.location.search
  const uri = `${locationOrigin + platformApiMountedAt() + path + queryParts}`

  return uri
}

SpreeCheckout.localizedPathFor = function (path) {
  const defaultLocale = this.localization.default_locale
  const currentLocale = this.localization.current_locale

  const defaultCurrency = this.localization.default_currency
  const currentCurrency = this.localization.current_currency

  if (defaultLocale !== currentLocale || defaultCurrency !== currentCurrency) {
    const fullUrl = new URL(pathFor(path))
    const params = fullUrl.searchParams
    const pathName = fullUrl.pathname

    params.set('locale', currentLocale)
    params.set('currency', currentCurrency)

    return fullUrl.origin + pathName + '?' + params.toString()
  }
  return pathFor(path)
}
