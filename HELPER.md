```bash
rm -rf dist build *.egg-info
```

```bash
uv build
```


```bash
uv tool install dist/one_click_drf-0.1.0-py3-none-any.whl
```

```bash
 ocd --help
 ```


 ```bash
 uv run twine upload dist/*
 ```


```bash
 source .venv/bin/activate
 ```

 ```bash
 uv pip install -e .
 ```


 ```bash
 ocd init demo_project --all
 ```

```bash
1. edit files
2. git add .
3. git commit -m "message"
4. git tag vX.Y.Z
5. git push origin main
6. git push origin vX.Y.Z
```
 

```bash
git checkout dev
# code
git commit
git push

```

```bash
git checkout main
git merge dev
git tag v0.1.1
git push origin main --tags
```


 ```bash
git tag -d v0.1.1
git push --delete origin v0.1.1
git tag v0.1.1
git push origin v0.1.1
 ```