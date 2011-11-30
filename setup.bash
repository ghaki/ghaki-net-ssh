export GK_PROJECT_IDEPS=( \
  "${GK_PROJECT_DIR}/../ghaki-account/lib" \
  "${GK_PROJECT_DIR}/../ghaki-app/lib" \
  "${GK_PROJECT_DIR}/../ghaki-ext-file/lib" \
  "${GK_PROJECT_DIR}/../ghaki-logger/lib" \
  "${GK_PROJECT_DIR}/../ghaki-match/lib" \
  )

export GK_PROJECT_GO_DIRS=( \
  "lib:${GK_PROJECT_DIR}/lib/ghaki/net_ssh" \
  "spec:${GK_PROJECT_DIR}/spec/ghaki/net_ssh" \
  "bin:${GK_PROJECT_DIR}/bin" \
  )
