---
title:  "Neomutt Default Functions and Bindings"
author: "David Nebauer"
date:   "8 October 2022"
style:  [Standard, Latex14pt, PageBreak]
        # Latex8-12|14|17|20pt; SectNewpage; Include
...

\newpage

------------------------------------------------------------------------------
Key           Function              Description
------------- --------------------- ------------------------------------------
<Enter>       select-entry          select the current entry

^L            refresh               clear and redraw the screen

<Return>      select-entry          select the current entry

<Esc>/        search-reverse        search backwards for a regular expression

!             shell-escape          invoke a command in a subshell

*             last-entry            move to the last entry

/             search                search for a regular expression

1             jump                  jump to an index number

2             jump                  jump to an index number

3             jump                  jump to an index number

4             jump                  jump to an index number

5             jump                  jump to an index number

6             jump                  jump to an index number

7             jump                  jump to an index number

8             jump                  jump to an index number

9             jump                  jump to an index number

:             enter-command         enter a neomuttrc command

;             tag-prefix            apply next function to tagged messages

<             previous-line         scroll up one line

=             first-entry           move to the first entry

>             next-line             scroll down one line

?             help                  this screen

H             top-page              move to the top of the page

L             bottom-page           move to the bottom of the page

M             middle-page           move to the middle of the page

Z             previous-page         move to the previous page

[             half-up               scroll up 1/2 page

]             half-down             scroll down 1/2 page

j             next-entry            move to the next entry

k             previous-entry        move to the previous entry

n             search-next           search for next match

t             tag-entry             tag the current entry

z             next-page             move to the next page

<Down>        next-entry            move to the next entry

<Up>          previous-entry        move to the previous entry

<Left>        previous-page         move to the previous page

<Right>       next-page             move to the next page

<Home>        first-entry           move to the first entry

<PageDown>    next-page             move to the next page

<PageUp>      previous-page         move to the previous page

<KeypadEnter> select-entry          select the current entry

<End>         last-entry            move to the last entry
------------------------------------------------------------------------------

Table: Generic {#tbl:default-generic}

\newpage

------------------------------------------------------------------------------
Key           Function                    Description
------------- --------------------------- ------------------------------------
^D            delete-thread               delete all messages in thread

^E            edit-type                   edit attachment content type

^F            forget-passphrase           wipe passphrases from memory

<Tab>         next-new-then-unread        jump to the next new or unread
                                          message

<Enter>       display-message             display a message

^K            extract-keys                extract supported public keys

<Return>      display-message             display a message

^N            next-thread                 jump to the next thread

^P            previous-thread             jump to previous thread

^R            read-thread                 mark the current thread as read

^T            untag-pattern               untag messages matching a pattern

^U            undelete-thread             undelete all messages in thread

<Esc><Tab>    previous-new-then-unread    jump to the previous new or unread
                                          message

<Esc>C        decode-copy                 make decoded (text/plain) copy

<Esc>P        check-traditional-pgp       check for classic PGP

<Esc>V        collapse-all                collapse/uncollapse all threads

<Esc>c        change-folder-readonly      open a different folder in read
                                          only mode

<Esc>d        delete-subthread            delete all messages in subthread

<Esc>e        resend-message              use the current message as a
                                          template for a new one

<Esc>i        change-newsgroup-readonly   open a different newsgroup in read
                                          only mode

<Esc>k        mail-key                    mail a PGP public key

<Esc>l        show-limit                  show currently active limit pattern

<Esc>n        next-subthread              jump to the next subthread

<Esc>p        previous-subthread          jump to previous subthread

<Esc>r        read-subthread              mark the current subthread as read

<Esc>s        decode-save                 make decoded copy (text/plain) and
                                          delete

<Esc>t        tag-thread                  tag the current thread

<Esc>u        undelete-subthread          undelete all messages in subthread

<Esc>v        collapse-thread             collapse/uncollapse current thread

<Space>       display-message             display a message

\#            break-thread                break the thread in two

$             sync-mailbox                save changes to mailbox

%             toggle-write                toggle whether the mailbox will be
                                          rewritten

&             link-threads                link tagged message to the current
                                          one

.             mailbox-list                list mailboxes with new mail

@             display-address             display full address of sender

A             autocrypt-acct-menu         manage autocrypt accounts

C             copy-message                copy a message to a file/mailbox

D             delete-pattern              delete messages matching a pattern

F             flag-message                toggle a message's 'important' flag

G             fetch-mail                  retrieve mail from POP server

J             next-entry                  move to the next entry

K             previous-entry              move to the previous entry

L             list-reply                  reply to specified mailing list

M             show-log-messages           show log (and debug) messages

N             toggle-new                  toggle a message's 'new' flag

O             sort-reverse                sort messages in reverse order

P             parent-message              jump to parent message in thread

Q             query                       query external program for addresses

R             recall-message              recall a postponed message

T             tag-pattern                 tag messages matching a pattern

U             undelete-pattern            undelete messages matching a pattern

V             show-version                show the NeoMutt version number and
                                          date

W             clear-flag                  clear a status flag from a message

Y             edit-label                  add, change, or delete a message's
                                          label

a             create-alias                create an alias from a message
                                          sender

b             bounce-message              remail a message to another user

c             change-folder               open a different folder

d             delete-message              delete the current entry

e             edit-or-view-raw-message    edit the raw message if the mailbox
                                          is not read-only, otherwise view it

f             forward-message             forward a message with comments

g             group-reply                 reply to all recipients

h             display-toggle-weed         display message and toggle header
                                          weeding

i             change-newsgroup            open a different newsgroup

j             next-undeleted              move to the next undeleted message

k             previous-undeleted          move to the previous undeleted
                                          message

l             limit                       show only messages matching a
                                          pattern

m             mail                        compose a new mail message

o             sort-mailbox                sort messages

p             print-message               print the current entry

q             quit                        save changes to mailbox and quit

r             reply                       reply to a message

s             save-message                save message/attachment to a
                                          mailbox/file

u             undelete-message            undelete the current entry

v             view-attachments            show MIME attachments

w             set-flag                    set a status flag on a message

x             exit                        exit this menu

|             pipe-entry                  pipe message/attachment to a shell
                                          command

~             mark-message                create a hotkey macro for the
                                          current message

<Down>        next-undeleted              move to the next undeleted message

<Up>          previous-undeleted          move to the previous undeleted
                                          message

<KeypadEnter> display-message             display a message

              alias-dialog                open the aliases dialog

              catchup                     mark all articles in newsgroup as
                                          read

              change-vfolder              open a different virtual folder

              compose-to-sender           compose new message to the current
                                          message sender

              decrypt-copy                make decrypted copy

              decrypt-save                make decrypted copy and delete

              edit                        edit the raw message (edit and
                                          edit-raw-message are synonyms)

              edit-raw-message            edit the raw message (edit and
                                          edit-raw-message are synonyms)

              entire-thread               read entire thread of the current
                                          message

              followup-message            followup to newsgroup

              forward-to-group            forward to newsgroup

              get-children                get all children of the current
                                          message

              get-message                 get message with Message-Id

              get-parent                  get parent of the current message

              group-chat-reply            reply to all recipients preserving
                                          To/Cc

              imap-fetch-mail             force retrieval of mail from IMAP
                                          server

              imap-logout-all             logout from all IMAP servers

              limit-current-thread        limit view to current thread

              list-subscribe              subscribe to a mailing list

              list-unsubscribe            unsubscribe from a mailing list

              modify-labels               modify (notmuch/imap) tags

              modify-labels-then-hide     modify (notmuch/imap) tags and then
                                          hide message

              modify-tags                 modify (notmuch/imap) tags

              modify-tags-then-hide       modify (notmuch/imap) tags and then
                                          hide message

              next-new                    jump to the next new message

              next-unread                 jump to the next unread message

              next-unread-mailbox         open next mailbox with new mail

              post-message                post message to newsgroup

              previous-new                jump to the previous new message

              previous-unread             jump to the previous unread message

              purge-message               delete the current entry, bypassing
                                          the trash folder

              purge-thread                delete the current thread,
                                          bypassing the trash folder

              quasi-delete                delete from NeoMutt, don't touch on
                                          disk

              reconstruct-thread          reconstruct thread containing
                                          current message

              root-message                jump to root message in thread

              sidebar-first               move the highlight to the first
                                          mailbox

              sidebar-last                move the highlight to the last
                                          mailbox

              sidebar-next                move the highlight to next mailbox

              sidebar-next-new            move the highlight to next mailbox
                                          with new mail

              sidebar-open                open highlighted mailbox

              sidebar-page-down           scroll the sidebar down 1 page

              sidebar-page-up             scroll the sidebar up 1 page

              sidebar-prev                move the highlight to previous
                                          mailbox

              sidebar-prev-new            move the highlight to previous
                                          mailbox with new mail

              sidebar-toggle-virtual      toggle between mailboxes and
                                          virtual mailboxes

              sidebar-toggle-visible      make the sidebar (in)visible

              tag-subthread               tag the current subthread

              toggle-read                 toggle view of read messages

              vfolder-from-query          generate virtual folder from query

              vfolder-from-query-readonly generate a read-only virtual folder
                                          from query

              vfolder-window-backward     shifts virtual folder time window
                                          backwards

              vfolder-window-forward      shifts virtual folder time window
                                          forwards

              vfolder-window-reset        resets virtual folder time window
                                          to the present

              view-raw-message            show the raw message

              check-stats                 calculate message statistics for
                                          all mailboxes

              current-bottom              move entry to bottom of screen

              current-middle              move entry to middle of screen

              current-top                 move entry to top of screen

              end-cond                    end of conditional execution (noop)

              jump                        jump to an index number

              search-opposite             search for next match in opposite
                                          direction

              tag-prefix-cond             apply next function ONLY to tagged
                                          messages

              what-key                    display the keycode for a key press
------------------------------------------------------------------------------

Table: Index {#tbl:default-index}

\newpage

------------------------------------------------------------------------------
Key           Function                    Description
------------- ---------------------       ------------------------------------
^D            delete-thread               delete all messages in thread

^E            edit-type                   edit attachment content type

^F            forget-passphrase           wipe passphrases from memory

<Tab>         next-new-then-unread        jump to the next new or unread
                                          message

<Enter>       next-line                   scroll down one line

^K            extract-keys                extract supported public keys

^L            redraw-screen               clear and redraw the screen

<Return>      next-line                   scroll down one line

^N            next-thread                 jump to the next thread

^P            previous-thread             jump to previous thread

^R            read-thread                 mark the current thread as read

^U            undelete-thread             undelete all messages in thread

<Esc>/        search-reverse              search backwards for a regular
                                          expression

<Esc>C        decode-copy                 make decoded (text/plain) copy

<Esc>P        check-traditional-pgp       check for classic PGP

<Esc>c        change-folder-readonly      open a different folder in read
                                          only mode

<Esc>d        delete-subthread            delete all messages in subthread

<Esc>e        resend-message              use the current message as a
                                          template for a new one

<Esc>k        mail-key                    mail a PGP public key

<Esc>n        next-subthread              jump to the next subthread

<Esc>p        previous-subthread          jump to previous subthread

<Esc>r        read-subthread              mark the current subthread as read

<Esc>s        decode-save                 make decoded copy (text/plain) and
                                          delete

<Esc>u        undelete-subthread          undelete all messages in subthread

<Space>       next-page                   move to the next page

!             shell-escape                invoke a command in a subshell

\#            break-thread                break the thread in two

$             sync-mailbox                save changes to mailbox

%             toggle-write                toggle whether the mailbox will be
                                          rewritten

&             link-threads                link tagged message to the current
                                          one

-             previous-page               move to the previous page

.             mailbox-list                list mailboxes with new mail

/             search                      search for a regular expression

1             jump                        jump to an index number

2             jump                        jump to an index number

3             jump                        jump to an index number

4             jump                        jump to an index number

5             jump                        jump to an index number

6             jump                        jump to an index number

7             jump                        jump to an index number

8             jump                        jump to an index number

9             jump                        jump to an index number

:             enter-command               enter a neomuttrc command

?             help                        this screen

@             display-address             display full address of sender

C             copy-message                copy a message to a file/mailbox

F             flag-message                toggle a message's 'important' flag

H             skip-headers                jump to first line after headers

J             next-entry                  move to the next entry

K             previous-entry              move to the previous entry

L             list-reply                  reply to specified mailing list

N             mark-as-new                 toggle a message's 'new' flag

O             sort-reverse                sort messages in reverse order

P             parent-message              jump to parent message in thread

Q             quit                        save changes to mailbox and quit

R             recall-message              recall a postponed message

S             skip-quoted                 skip beyond quoted text

T             toggle-quoted               toggle display of quoted text

V             show-version                show the NeoMutt version number and
                                          date

W             clear-flag                  clear a status flag from a message

Y             edit-label                  add, change, or delete a message's
                                          label

\             search-toggle               toggle search pattern coloring

^             top                         jump to the top of the message

a             create-alias                create an alias from a message
                                          sender

b             bounce-message              remail a message to another user

c             change-folder               open a different folder

d             delete-message              delete the current entry

e             edit-or-view-raw-message    edit the raw message if the mailbox
                                          is not read-only, otherwise view it

f             forward-message             forward a message with comments

g             group-reply                 reply to all recipients

h             display-toggle-weed         display message and toggle header
                                          weeding

i             exit                        exit this menu

j             next-undeleted              move to the next undeleted message

k             previous-undeleted          move to the previous undeleted
                                          message

m             mail                        compose a new mail message

n             search-next                 search for next match

o             sort-mailbox                sort messages

p             print-message               print the current entry

q             exit                        exit this menu

r             reply                       reply to a message

s             save-message                save message/attachment to a
                                          mailbox/file

t             tag-message                 tag the current entry

u             undelete-message            undelete the current entry

v             view-attachments            show MIME attachments

w             set-flag                    set a status flag on a message

x             exit                        exit this menu

|             pipe-entry                  pipe message/attachment to a shell
                                          command

<Down>        next-undeleted              move to the next undeleted message

<Up>          previous-undeleted          move to the previous undeleted
                                          message

<Left>        previous-undeleted          move to the previous undeleted
                                          message

<Right>       next-undeleted              move to the next undeleted message

<Home>        top                         jump to the top of the message

<BackSpace>   previous-line               scroll up one line

<PageDown>    next-page                   move to the next page

<PageUp>      previous-page               move to the previous page

<KeypadEnter> next-line                   scroll down one line

<End>         bottom                      jump to the bottom of the message

              change-newsgroup            open a different newsgroup

              change-newsgroup-readonly   open a different newsgroup in read
                                          only mode

              change-vfolder              open a different virtual folder

              check-stats                 calculate message statistics for
                                          all mailboxes

              compose-to-sender           compose new message to the current
                                          message sender

              decrypt-copy                make decrypted copy

              decrypt-save                make decrypted copy and delete

              edit                        edit the raw message (edit and
                                          edit-raw-message are synonyms)

              edit-raw-message            edit the raw message (edit and
                                          edit-raw-message are synonyms)

              entire-thread               read entire thread of the current
                                          message

              followup-message            followup to newsgroup

              forward-to-group            forward to newsgroup

              group-chat-reply            reply to all recipients preserving
                                          To/Cc

              half-down                   scroll down 1/2 page

              half-up                     scroll up 1/2 page

              imap-fetch-mail             force retrieval of mail from IMAP
                                          server

              imap-logout-all             logout from all IMAP servers

              jump                        jump to an index number

              list-subscribe              subscribe to a mailing list

              list-unsubscribe            unsubscribe from a mailing list

              modify-labels               modify (notmuch/imap) tags

              modify-labels-then-hide     modify (notmuch/imap) tags and then
                                          hide message

              modify-tags                 modify (notmuch/imap) tags

              modify-tags-then-hide       modify (notmuch/imap) tags and then
                                          hide message

              next-new                    jump to the next new message

              next-unread                 jump to the next unread message

              next-unread-mailbox         open next mailbox with new mail

              post-message                post message to newsgroup

              previous-new                jump to the previous new message

              previous-new-then-unread    jump to the previous new or unread
                                          message

              previous-unread             jump to the previous unread message

              print-entry                 print the current entry

              purge-message               delete the current entry, bypassing
                                          the trash folder

              purge-thread                delete the current thread,
                                          bypassing the trash folder

              quasi-delete                delete from NeoMutt, don't touch on
                                          disk

              reconstruct-thread          reconstruct thread containing
                                          current message

              root-message                jump to root message in thread

              save-entry                  save message/attachment to a
                                          mailbox/file

              search-opposite             search for next match in opposite
                                          direction

              show-log-messages           show log (and debug) messages

              sidebar-first               move the highlight to the first
                                          mailbox

              sidebar-last                move the highlight to the last
                                          mailbox

              sidebar-next                move the highlight to next mailbox

              sidebar-next-new            move the highlight to next mailbox
                                          with new mail

              sidebar-open                open highlighted mailbox

              sidebar-page-down           scroll the sidebar down 1 page

              sidebar-page-up             scroll the sidebar up 1 page

              sidebar-prev                move the highlight to previous
                                          mailbox

              sidebar-prev-new            move the highlight to previous
                                          mailbox with new mail

              sidebar-toggle-virtual      toggle between mailboxes and
                                          virtual mailboxes

              sidebar-toggle-visible      make the sidebar (in)visible

              vfolder-from-query          generate virtual folder from query

              vfolder-from-query-readonly a read-only virtual folder from
                                          query

              view-raw-message            show the raw message

              what-key                    display the keycode for a key press

              error-history               show log (and debug) messages
------------------------------------------------------------------------------

Table: Pager {#tbl:default-pager}

\newpage

------------------------------------------------------------------------------
Key           Function              Description
------------- --------------------- ------------------------------------------
^E            edit-type             edit attachment content type

^F            forget-passphrase     wipe passphrases from memory

<Enter>       view-attach           view attachment using mailcap entry if
                                    necessary

^K            extract-keys          extract supported public keys

<Return>      view-attach           view attachment using mailcap entry if
                                    necessary

<Esc>P        check-traditional-pgp check for classic PGP

<Esc>e        resend-message        use the current message as a template for
                                    a new one

L             list-reply            reply to specified mailing list

T             view-text             view attachment as text

b             bounce-message        remail a message to another user

d             delete-entry          delete the current entry

f             forward-message       forward a message with comments

g             group-reply           reply to all recipients

h             display-toggle-weed   display message and toggle header weeding

m             view-mailcap          force viewing of attachment using mailcap

p             print-entry           print the current entry

q             exit                  exit this menu

r             reply                 reply to a message

s             save-entry            save message/attachment to a mailbox/file

u             undelete-entry        undelete the current entry

v             collapse-parts        toggle display of subparts

|             pipe-entry            pipe message/attachment to a shell command

<KeypadEnter> view-attach           view attachment using mailcap entry if
                                    necessary

              compose-to-sender     compose new message to the current message
                                    sender

              followup-message      followup to newsgroup

              forward-to-group      forward to newsgroup

              group-chat-reply      reply to all recipients preserving To/Cc

              list-subscribe        subscribe to a mailing list

              list-unsubscribe      unsubscribe from a mailing list

              view-pager            view attachment in pager using
                                    copiousoutput mailcap

              check-stats           calculate message statistics for all
                                    mailboxes

              current-bottom        move entry to bottom of screen

              current-middle        move entry to middle of screen

              current-top           move entry to top of screen

              end-cond              end of conditional execution (noop)

              jump                  jump to an index number

              search-opposite       search for next match in opposite
                                    direction

              show-log-messages     show log (and debug) messages

              tag-prefix-cond       apply next function ONLY to tagged
                                    messages

              what-key              display the keycode for a key press

              error-history         show log (and debug) messages
------------------------------------------------------------------------------

Table: Attachments {#tbl:default-attach}
