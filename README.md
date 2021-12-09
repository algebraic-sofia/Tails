# Llama 

Llama is an implementation of version 340 of the minecraft protocol that will use Idris2 and Nix. This project aims to make some cool usage of dependent and linear types to make it easier to avoid bugs. Some of the relevent goals of it will be listed here:

## Goals:
- [ ] Extensive use of dependent types and linear types to make it easier to prove correct.
- [ ] The development of libraries and tools for other projects on idris.
- [ ] Creation of an API to the creation of plugins.
- [ ] Check if the implementation of a simple "hot code reload" is possible for plugins.

## Problems:
- Probably many essential things like a good `buffer` library are not available, so we'll need to implement them.

## Resources

#### Protocol
- The protocol documentation: https://wiki.vg/index.php?title=Protocol&oldid=14204
- How to write a server: https://wiki.vg/How_to_Write_a_Server
- NBT Format: https://wiki.vg/NBT

#### Idris
- https://idris2.readthedocs.io/en/latest/tutorial/index.html
- https://www.manning.com/books/type-driven-development-with-idris
