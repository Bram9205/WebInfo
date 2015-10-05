<?php

/**
 * Sets of HTML tag removal rules used when a page is processed during crawling. 
 *
 * @author Guus
 */
class PageProcessRules {

    /**
     * HTML tags whose elements should be removed from the DOM when crawling
     */
    public static $REMOVE_TAGS = [
        'script', 'a', 'iframe', 'link', 'img', 'head', 'style', 'input', 'ul', 'ol', 'nav', 'video', 'aside', 'button'
    ];
    
    /**
     * CSS Classes whose elements should be removed during crawling
     */
    public static $REMOVE_CLASSES = [
        'footer', 'page-footer', 'article-footer', 'videoplayer', 'mediaplayer', 'overlay', 'cookies', 'share'
    ];

}
