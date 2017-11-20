# -*- coding: utf-8 -*-
import helloworld
import io


def test_main():
    file = io.StringIO()
    helloworld.main(file=file)
    assert file.getvalue() == 'Hello World!\n'
