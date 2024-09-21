default:
  target: dev
  outputs:
    dev:
      type: {{ .type }}
      location: {{ .location }}
    credentials:
      user: {{ .user }}
      password: {{ .password }}
