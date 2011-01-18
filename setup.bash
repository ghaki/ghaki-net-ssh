export GK_PROJECT_IDEPS=( \
  "$(pwd)/../ghaki-account/lib" \
  "$(pwd)/../ghaki-core/lib" \
  "$(pwd)/../ghaki-logger/lib" \
  )
export GK_PROJECT_GO_DIRS=( \
  "lib:${GK_PROJECT_DIR}/lib/ghaki/net_ssh" \
  "spec:${GK_PROJECT_DIR}/spec/ghaki/net_ssh" \
  "bin:${GK_PROJECT_DIR}/bin" \
  )
