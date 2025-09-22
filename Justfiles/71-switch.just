# Run a one minute system benchmark
[group('Apps')]
benchmark:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    find ~/.kube/.switch_tmp -type f -exec sed -i '\''s/&#43;/+/g'\'' {} '\'';'\''
    find ~/.kube/cache -type f -exec sed -i '\''s/&#43;/+/g'\'' {} '\'';'\''
    find ~/.kube/qa-cache -type f -exec sed -i '\''s/&#43;/+/g'\'' {} '\'';'\''
