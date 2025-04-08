# Known issues

If you see

```
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

when starting rails server just add `PGGSSENCMODE=disable` to your `.env` file. This is not related to Rails, see more info here - https://github.com/rails/rails/issues/38560#issuecomment-1881733872.

